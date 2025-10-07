import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // TODO: Register Hive adapters for models
  // Hive.registerAdapter(UserAdapter());
  // Hive.registerAdapter(WalletAdapter());
  // Hive.registerAdapter(TransactionAdapter());
  // Hive.registerAdapter(BudgetAdapter());

  // TODO: Open Hive boxes
  // await Hive.openBox('users');
  // await Hive.openBox('wallets');
  // await Hive.openBox('transactions');
  // await Hive.openBox('budgets');
  // await Hive.openBox('settings');

  runApp(const YaBikeApp());
}
