import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // TODO: Register Hive adapters for models (will be generated)
  // Hive.registerAdapter(WalletAdapter());
  // Hive.registerAdapter(TransactionAdapter());
  // Hive.registerAdapter(BudgetAdapter());
  // Hive.registerAdapter(BackupDataAdapter());

  // Open Hive boxes (using dynamic for now, will add type adapters later)
  await Hive.openBox('wallets');
  await Hive.openBox('transactions');
  await Hive.openBox('budgets');
  await Hive.openBox('settings');
  await Hive.openBox('backups');

  // Initialize Supabase with your actual configuration
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const YaBikeApp());
}
