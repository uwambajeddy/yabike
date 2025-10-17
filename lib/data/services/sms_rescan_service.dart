import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';
import 'sms_parser_service.dart';

/// Service for rescanning SMS messages and importing new transactions
class SmsRescanService {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final WalletRepository _walletRepository = WalletRepository();

  /// Rescan SMS messages and import new transactions
  /// Returns the number of new transactions imported
  Future<int> rescanAndImportNewTransactions() async {
    try {
      debugPrint('\n====== RESCANNING SMS MESSAGES ======');
      
      // Check if we have permission
      final status = await Permission.sms.status;
      if (!status.isGranted) {
        debugPrint('❌ SMS permission not granted');
        return 0;
      }

      // Get existing transaction IDs to avoid duplicates
      final existingTransactions = _transactionRepository.getAllTransactions();
      final existingIds = existingTransactions.map((t) => t.id).toSet();
      
      debugPrint('📊 Existing transactions: ${existingIds.length}');

      // Query SMS messages from known senders
      final query = SmsQuery();
      final List<SmsMessage> allMessages = [];

      // Get messages from Equity Bank
      try {
        final equityMessages = await query.querySms(
          address: 'EQUITYBANK',
        );
        allMessages.addAll(equityMessages);
        debugPrint('📨 Found ${equityMessages.length} Equity Bank messages');
      } catch (e) {
        debugPrint('⚠️ Error querying Equity Bank messages: $e');
      }

      // Get messages from MTN MoMo
      try {
        final momoMessages = await query.querySms(
          address: 'M-Money',
        );
        allMessages.addAll(momoMessages);
        debugPrint('📨 Found ${momoMessages.length} MTN MoMo messages');
      } catch (e) {
        debugPrint('⚠️ Error querying MTN MoMo messages: $e');
      }

      debugPrint('📱 Total SMS messages to scan: ${allMessages.length}');

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

      debugPrint('\n====== RESCAN SUMMARY ======');
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
      
      debugPrint('==============================\n');

      return newTransactions.length;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in rescanAndImportNewTransactions: $e');
      debugPrint('Stack trace: $stackTrace');
      return 0;
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
