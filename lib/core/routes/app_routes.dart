import 'package:flutter/material.dart';

/// App route names
class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Authentication
  static const String createPin = '/auth/create-pin';
  static const String confirmPin = '/auth/confirm-pin';
  static const String setupBiometric = '/auth/setup-biometric';
  static const String setupComplete = '/auth/setup-complete';
  static const String unlock = '/auth/unlock';

  // Main App
  static const String home = '/home';
  static const String main = '/main';

  // Wallets
  static const String wallets = '/wallets';
  static const String walletDetail = '/wallets/detail';
  static const String createWallet = '/wallets/create';
  static const String editWallet = '/wallets/edit';

  // Transactions
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/detail';
  static const String addTransaction = '/transactions/add';
  static const String editTransaction = '/transactions/edit';
  static const String reassignTransaction = '/transactions/reassign';
  static const String filterTransactions = '/transactions/filter';

  // Budgets
  static const String budgets = '/budgets';
  static const String budgetDetail = '/budgets/detail';
  static const String createBudget = '/budgets/create';
  static const String editBudget = '/budgets/edit';
  static const String selectCategory = '/budgets/select-category';

  // Settings
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String security = '/settings/security';
  static const String appearance = '/settings/appearance';
  static const String notifications = '/settings/notifications';
  static const String dataManagement = '/settings/data-management';
}

/// Route generator for named routes
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // SplashScreen(),
          settings: settings,
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // OnboardingScreen(),
          settings: settings,
        );

      case AppRoutes.createPin:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // CreatePinScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // HomeScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
