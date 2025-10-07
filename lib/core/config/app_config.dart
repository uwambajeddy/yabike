/// App-wide configuration constants
class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'YaBike';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Security
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const int maxPinAttempts = 3;
  static const int autoLockDuration = 300; // 5 minutes in seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Transaction Categories
  static const List<String> transactionCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Utilities',
    'Health',
    'Education',
    'Transfer',
    'Salary',
    'Others',
  ];

  // Wallet Types
  static const List<String> walletTypes = [
    'MoMo',
    'Bank',
    'Cash',
  ];

  // Budget Periods
  static const List<String> budgetPeriods = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  // Currency
  static const String defaultCurrency = 'RWF';
  static const List<String> supportedCurrencies = [
    'RWF',
    'USD',
    'EUR',
  ];

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';

  // Chart Settings
  static const int chartDataPoints = 7;
  static const int maxChartBars = 12;

  // SMS Parsing
  static const List<String> smsProviders = [
    'MTN',
    'AIRTEL',
    'EQUITYBANK',
    'BK',
    'I&M',
    'COGEBANQUE',
  ];

  // Local Storage Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserPin = 'user_pin';
  static const String keyUseBiometric = 'use_biometric';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastSync = 'last_sync';
}
