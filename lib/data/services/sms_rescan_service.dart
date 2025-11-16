import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart'; // Disabled with SMS
// import '../models/transaction_model.dart'; // Disabled with SMS 
// import '../repositories/transaction_repository.dart'; // Disabled with SMS
// import '../repositories/wallet_repository.dart'; // Disabled with SMS
// import 'sms_parser_service.dart'; // Disabled with SMS

/// Service for rescanning SMS messages and importing new transactions
/// TEMPORARILY DISABLED due to SMS package compatibility issues
class SmsRescanService {
  // Temporarily disabled repositories
  // final TransactionRepository _transactionRepository = TransactionRepository();
  // final WalletRepository _walletRepository = WalletRepository();
  
  static const String _lastScanKey = 'last_sms_scan_timestamp';
  static const String _lastScanCountKey = 'last_sms_scan_count';

  /// Rescan SMS messages and import new transactions
  /// Returns the number of new transactions imported
  /// 
  /// [forceFullScan] - If true, scans all messages. If false (default), only scans new messages since last scan.
  Future<int> rescanAndImportNewTransactions({bool forceFullScan = false}) async {
    try {
      debugPrint('\n====== RESCANNING SMS MESSAGES ======');
      debugPrint('⚠️ SMS rescan is temporarily disabled due to package compatibility');
      debugPrint('==============================\n');
      return 0;
    } catch (e) {
      debugPrint('❌ ERROR in rescanAndImportNewTransactions: $e');
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

  /* TEMPORARILY DISABLED SMS-RELATED METHODS
  
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
  
  END OF DISABLED SMS METHODS */
}
