import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';
import 'sms_parser_service.dart';

/// Service for rescanning SMS messages and importing new transactions
class SmsRescanService {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final WalletRepository _walletRepository = WalletRepository();
  
  static const String _lastScanKey = 'last_sms_scan_timestamp';
  static const String _lastScanCountKey = 'last_sms_scan_count';

  /// Rescan SMS messages and import new transactions
  /// Returns the number of new transactions imported
  /// 
  /// [forceFullScan] - If true, scans all messages. If false (default), only scans new messages since last scan.
  Future<int> rescanAndImportNewTransactions({bool forceFullScan = false}) async {
    try {
      debugPrint('\n====== RESCANNING SMS MESSAGES ======');
      debugPrint('🔍 Scan mode: ${forceFullScan ? "FULL SCAN" : "INCREMENTAL (new messages only)"}');
      
      // Check if we have permission
      final status = await Permission.sms.status;
      if (!status.isGranted) {
        debugPrint('❌ SMS permission not granted');
        return 0;
      }

      // Get last scan timestamp
      final prefs = await SharedPreferences.getInstance();
      final lastScanTimestamp = prefs.getInt(_lastScanKey);
      final lastScanCount = prefs.getInt(_lastScanCountKey) ?? 0;
      
      DateTime? scanFromDate;
      if (!forceFullScan && lastScanTimestamp != null) {
        scanFromDate = DateTime.fromMillisecondsSinceEpoch(lastScanTimestamp);
        debugPrint('📅 Last scan: ${scanFromDate.toString()}');
        debugPrint('📊 Messages scanned in last run: $lastScanCount');
      } else {
        debugPrint('📅 No previous scan found or forcing full scan');
      }

      // Get existing transaction IDs to avoid duplicates
      final existingTransactions = _transactionRepository.getAllTransactions();
      final existingIds = existingTransactions.map((t) => t.id).toSet();
      
      debugPrint('📊 Existing transactions in DB: ${existingIds.length}');

      // Query SMS messages from known senders
      final query = SmsQuery();
      final List<SmsMessage> allMessages = [];
      final startTime = DateTime.now();

      // Get messages from Equity Bank (only after last scan date if incremental)
      try {
        final equityMessages = await query.querySms(
          address: 'EQUITYBANK',
          start: scanFromDate?.millisecondsSinceEpoch,
        );
        allMessages.addAll(equityMessages);
        debugPrint('📨 Found ${equityMessages.length} Equity Bank messages${scanFromDate != null ? " (since $scanFromDate)" : ""}');
      } catch (e) {
        debugPrint('⚠️ Error querying Equity Bank messages: $e');
      }

      // Get messages from MTN MoMo (only after last scan date if incremental)
      try {
        final momoMessages = await query.querySms(
          address: 'M-Money',
          start: scanFromDate?.millisecondsSinceEpoch,
        );
        allMessages.addAll(momoMessages);
        debugPrint('📨 Found ${momoMessages.length} MTN MoMo messages${scanFromDate != null ? " (since $scanFromDate)" : ""}');
      } catch (e) {
        debugPrint('⚠️ Error querying MTN MoMo messages: $e');
      }

      debugPrint('📱 Total SMS messages to scan: ${allMessages.length}');
      
      // If no new messages, return early
      if (allMessages.isEmpty) {
        debugPrint('✓ No new messages to scan');
        return 0;
      }

      // Parse messages and collect new transactions
      final List<Transaction> newTransactions = [];
      int skippedDuplicates = 0;
      int failedToParse = 0;

      for (final message in allMessages) {
        try {
          final address = message.address ?? '';
          final body = message.body ?? '';
          final date = message.date ?? DateTime.now();

          // Parse the SMS
          final transaction = SmsParserService.parseSms(body, address, date);

          if (transaction != null) {
            // Check if this is a new transaction
            if (!existingIds.contains(transaction.id)) {
              // Assign to existing wallet
              final walletId = _getWalletForTransaction(transaction);
              if (walletId != null) {
                final updatedTransaction = transaction.copyWith(
                  walletId: walletId,
                );
                newTransactions.add(updatedTransaction);
              } else {
                // If no wallet found, still add the transaction
                newTransactions.add(transaction);
              }
            } else {
              skippedDuplicates++;
            }
          } else {
            failedToParse++;
          }
        } catch (e) {
          debugPrint('❌ Error parsing message: $e');
          failedToParse++;
        }
      }

      final endTime = DateTime.now();
      final scanDuration = endTime.difference(startTime);
      
      debugPrint('\n====== RESCAN SUMMARY ======');
      debugPrint('⏱️  Scan duration: ${scanDuration.inMilliseconds}ms');
      debugPrint('✅ New transactions found: ${newTransactions.length}');
      debugPrint('⏭️  Skipped duplicates: $skippedDuplicates');
      debugPrint('❌ Failed to parse: $failedToParse');

      // Save new transactions to database
      if (newTransactions.isNotEmpty) {
        await _transactionRepository.addTransactions(newTransactions);
        debugPrint('💾 Saved ${newTransactions.length} new transactions to database');
        
        // Print breakdown
        final equityCount = newTransactions.where((t) => t.source == 'EQUITYBANK').length;
        final momoCount = newTransactions.where((t) => t.source == 'M-MONEY').length;
        debugPrint('   - Equity Bank: $equityCount');
        debugPrint('   - MTN MoMo: $momoCount');
      }
      
      // Update last scan timestamp
      await prefs.setInt(_lastScanKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_lastScanCountKey, allMessages.length);
      debugPrint('💾 Updated last scan timestamp');
      
      debugPrint('==============================\n');

      return newTransactions.length;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in rescanAndImportNewTransactions: $e');
      debugPrint('Stack trace: $stackTrace');
      return 0;
    }
  }

  /// Reset the last scan timestamp to force a full rescan on next import
  /// Useful for troubleshooting or when user wants to re-import all transactions
  Future<void> resetLastScanTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastScanKey);
      await prefs.remove(_lastScanCountKey);
      debugPrint('✅ Reset SMS scan timestamp - next scan will be a full scan');
    } catch (e) {
      debugPrint('❌ Error resetting scan timestamp: $e');
    }
  }

  /// Get the last scan timestamp
  Future<DateTime?> getLastScanTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastScanKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting last scan timestamp: $e');
      return null;
    }
  }

  /// Get the appropriate wallet for a transaction based on its source
  String? _getWalletForTransaction(Transaction transaction) {
    final wallets = _walletRepository.getActiveWallets();
    
    if (transaction.source == 'EQUITYBANK') {
      // Find Equity Bank wallet
      final wallet = wallets.firstWhere(
        (w) => w.provider == 'EquityBank' || w.name.contains('Equity'),
        orElse: () => wallets.first,
      );
      return wallet.id;
    } else if (transaction.source == 'M-MONEY') {
      // Find MTN MoMo wallet
      final wallet = wallets.firstWhere(
        (w) => w.provider == 'MTN' || w.name.contains('MTN') || w.name.contains('MoMo'),
        orElse: () => wallets.first,
      );
      return wallet.id;
    }
    
    return wallets.isNotEmpty ? wallets.first.id : null;
  }
}
