/// App-wide string constants
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'YaBike';
  static const String appVersion = '1.0.0';

  // Onboarding
  static const String onboarding1Title = 'Track Your Finances';
  static const String onboarding1Description =
      'Automatically import and track your transactions from SMS';
  static const String onboarding2Title = 'Manage Your Wallets';
  static const String onboarding2Description =
      'Create and manage multiple wallets for different sources';
  static const String onboarding3Title = 'Budget & Save';
  static const String onboarding3Description =
      'Set budgets and track your spending to achieve your goals';

  // Authentication
  static const String createPinTitle = 'Create Your PIN';
  static const String createPinDescription =
      'Set a 4-6 digit PIN to secure your app';
  static const String confirmPinTitle = 'Confirm Your PIN';
  static const String confirmPinDescription = 'Re-enter your PIN to confirm';
  static const String unlockTitle = 'Welcome Back';
  static const String unlockDescription = 'Enter your PIN to unlock';
  static const String setupBiometricTitle = 'Enable Biometric';
  static const String setupBiometricDescription =
      'Use fingerprint or face recognition for quick access';
  static const String setupCompleteTitle = 'You\'re All Set!';
  static const String setupCompleteDescription =
      'Start managing your finances with YaBike';

  // Common Actions
  static const String continueText = 'Continue';
  static const String skip = 'Skip';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String confirm = 'Confirm';
  static const String close = 'Close';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';

  // Home
  static const String homeTitle = 'Dashboard';
  static const String totalBalance = 'Total Balance';
  static const String recentTransactions = 'Recent Transactions';
  static const String seeAll = 'See All';
  static const String quickActions = 'Quick Actions';
  static const String addTransaction = 'Add Transaction';
  static const String createWallet = 'Create Wallet';
  static const String createBudget = 'Create Budget';

  // Wallets
  static const String walletsTitle = 'My Wallets';
  static const String walletDetails = 'Wallet Details';
  static const String addWallet = 'Add Wallet';
  static const String editWallet = 'Edit Wallet';
  static const String walletName = 'Wallet Name';
  static const String walletType = 'Wallet Type';
  static const String walletBalance = 'Balance';
  static const String walletProvider = 'Provider';
  static const String accountNumber = 'Account Number';
  static const String selectWallet = 'Select Wallet';

  // Transactions
  static const String transactionsTitle = 'Transactions';
  static const String transactionDetails = 'Transaction Details';
  static const String addNewTransaction = 'Add Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String reassignTransaction = 'Reassign Transaction';
  static const String filterTransactions = 'Filter';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String description = 'Description';
  static const String reference = 'Reference';
  static const String type = 'Type';
  static const String income = 'Income';
  static const String expense = 'Expense';

  // Budgets
  static const String budgetsTitle = 'Budgets';
  static const String budgetDetails = 'Budget Details';
  static const String addBudget = 'Add Budget';
  static const String editBudget = 'Edit Budget';
  static const String budgetName = 'Budget Name';
  static const String budgetAmount = 'Budget Amount';
  static const String budgetPeriod = 'Period';
  static const String budgetCategory = 'Category';
  static const String spent = 'Spent';
  static const String remaining = 'Remaining';
  static const String daysLeft = 'Days Left';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String profile = 'Profile';
  static const String security = 'Security';
  static const String appearance = 'Appearance';
  static const String notifications = 'Notifications';
  static const String dataManagement = 'Data Management';
  static const String about = 'About';
  static const String logout = 'Logout';

  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorNetwork = 'No internet connection';
  static const String errorInvalidInput = 'Invalid input';
  static const String errorPinMismatch = 'PINs do not match';
  static const String errorIncorrectPin = 'Incorrect PIN';
  static const String errorBiometricFailed = 'Biometric authentication failed';

  // Empty States
  static const String emptyTransactions = 'No transactions yet';
  static const String emptyWallets = 'No wallets yet';
  static const String emptyBudgets = 'No budgets yet';
  static const String emptySearch = 'No results found';

  // Validation
  static const String validationRequired = 'This field is required';
  static const String validationInvalidAmount = 'Invalid amount';
  static const String validationPinLength = 'PIN must be 4-6 digits';

  // Permissions
  static const String permissionSmsTitle = 'SMS Permission Required';
  static const String permissionSmsDescription =
      'We need access to read your transaction SMS to track your finances automatically';
  static const String permissionBiometricTitle = 'Biometric Permission Required';
  static const String permissionBiometricDescription =
      'Enable biometric authentication for quick and secure access';
}
