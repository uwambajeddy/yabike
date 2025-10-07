/// App-wide asset path constants
class AppAssets {
  AppAssets._();

  // Base paths
  static const String _imagesPath = 'assets/images';

  // Logo
  static const String logo = '$_imagesPath/logo.png';

  // Onboarding Images
  static const String budgetPlannerImage =
      '$_imagesPath/budget-planner-and-money.png';
  static const String checkmarkImage =
      '$_imagesPath/checkmark-illustration-and-coin-simple-3d-green.png';

  // Placeholder for empty states
  static const String emptyTransactions = '$_imagesPath/empty_transactions.png';
  static const String emptyWallets = '$_imagesPath/empty_wallets.png';
  static const String emptyBudgets = '$_imagesPath/empty_budgets.png';
}
