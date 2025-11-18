import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
<<<<<<< Updated upstream
=======
import 'data/services/backup_service.dart';
import 'data/services/sms_rescan_service.dart';
>>>>>>> Stashed changes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // TODO: Register Hive adapters for models (will be generated)
  // Hive.registerAdapter(WalletAdapter());
  // Hive.registerAdapter(TransactionAdapter());
  // Hive.registerAdapter(BudgetAdapter());

  // Open Hive boxes (using dynamic for now, will add type adapters later)
  await Hive.openBox('wallets');
  await Hive.openBox('transactions');
  await Hive.openBox('budgets');
  await Hive.openBox('settings');

<<<<<<< Updated upstream
  runApp(const YaBikeApp());
}
=======
  // Check and perform automatic backup if due
  _checkAndPerformAutomaticBackup();

  // Scan for new SMS transactions on app startup
  _scanForNewTransactions();

  runApp(const YaBikeApp());
}

/// Check if automatic backup is due and perform it in the background
void _checkAndPerformAutomaticBackup() async {
  try {
    final BackupService backupService = BackupService();
    await backupService.initialize();
    
    // Only attempt backup if user is signed in and backup is due
    if (backupService.isSignedIn && backupService.isBackupDue()) {
      debugPrint('Automatic backup is due, performing backup...');
      await backupService.backupData();
      debugPrint('Automatic backup completed successfully');
    }
  } catch (e) {
    debugPrint('Automatic backup failed: $e');
    // Fail silently - don't interrupt app startup
  }
}

/// Scan for new SMS transactions on app startup
void _scanForNewTransactions() async {
  try {
    // Check if SMS permission is granted
    final status = await Permission.sms.status;
    if (!status.isGranted) {
      debugPrint('SMS permission not granted, skipping auto-scan');
      return;
    }

    final smsRescanService = SmsRescanService();
    debugPrint('🔄 Scanning for new transactions on app startup...');
    final newCount = await smsRescanService.rescanAndImportNewTransactions();
    
    if (newCount > 0) {
      debugPrint('✅ Auto-imported $newCount new transaction(s) on app startup');
    } else {
      debugPrint('✓ No new transactions found');
    }
  } catch (e) {
    debugPrint('❌ Error scanning for new transactions: $e');
    // Fail silently - don't interrupt app startup
  }
}
>>>>>>> Stashed changes
