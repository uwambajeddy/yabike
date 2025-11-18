import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/services/backup_service.dart';

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

  // Check and perform automatic backup if due
  _checkAndPerformAutomaticBackup();

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
