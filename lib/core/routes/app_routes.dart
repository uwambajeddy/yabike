import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/viewmodels/home_viewmodel.dart';
import '../../features/wallet/screens/wallet_name_screen.dart';
import '../../features/wallet/viewmodels/create_wallet_viewmodel.dart';
import '../../features/sms_integration/screens/sms_terms_screen.dart';
import '../../features/sms_integration/screens/sms_loading_screen.dart';
import '../../features/sms_integration/viewmodels/sms_integration_viewmodel.dart';
import '../../features/transaction/screens/add_transaction_screen.dart';
import '../../features/transaction/viewmodels/add_transaction_viewmodel.dart';

/// App route names
class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // SMS Integration (Android)
  static const String smsTerms = '/sms/terms';
  static const String smsLoading = '/sms/loading';

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
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case AppRoutes.createPin:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // CreatePinScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomeScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.createWallet:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => CreateWalletViewModel(),
            child: const WalletNameScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.smsTerms:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => SmsIntegrationViewModel(),
            child: Builder(
              builder: (context) {
                // Provide the same ViewModel to both screens via navigation
                return const SmsTermsScreen();
              },
            ),
          ),
          settings: settings,
        );

      case AppRoutes.smsLoading:
        // The ViewModel MUST be passed as argument
        final viewModel = settings.arguments as SmsIntegrationViewModel?;
        
        if (viewModel == null) {
          // This should never happen - log error and create fallback
          debugPrint('⚠️ ERROR: SmsLoadingScreen requires SmsIntegrationViewModel argument!');
          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => SmsIntegrationViewModel(),
              child: const SmsLoadingScreen(),
            ),
            settings: settings,
          );
        }
        
        // Use ListenableProvider to keep the viewModel alive without owning it
        return MaterialPageRoute(
          builder: (_) => ListenableProvider.value(
            value: viewModel,
            child: const SmsLoadingScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.addTransaction:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => AddTransactionViewModel(),
            child: const AddTransactionScreen(),
          ),
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
