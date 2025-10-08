import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../viewmodels/sms_integration_viewmodel.dart';

class SmsLoadingScreen extends StatefulWidget {
  const SmsLoadingScreen({super.key});

  @override
  State<SmsLoadingScreen> createState() => _SmsLoadingScreenState();
}

class _SmsLoadingScreenState extends State<SmsLoadingScreen> {
  @override
  void initState() {
    super.initState();
    
    // Start SMS scan and listen to state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SmsIntegrationViewModel>();
      
      debugPrint('🔍 Loading Screen - Initial state: ${viewModel.state}');
      
      // Check if already completed
      if (viewModel.state == SmsIntegrationState.completed) {
        debugPrint('✅ Already completed - navigating immediately');
        _navigateToHome();
        return;
      } else if (viewModel.state == SmsIntegrationState.error) {
        debugPrint('❌ Already in error state');
        _showErrorDialog(viewModel.errorMessage ?? 'An error occurred');
        return;
      }
      
      // Add listener FIRST before starting scan
      debugPrint('📡 Adding listener for state changes');
      viewModel.addListener(_onStateChanged);
      
      // Then start scan if needed
      if (viewModel.state == SmsIntegrationState.permissionGranted) {
        debugPrint('🚀 Starting SMS scan...');
        viewModel.scanAndImportSms();
      }
    });
  }

  void _onStateChanged() {
    final viewModel = context.read<SmsIntegrationViewModel>();
    
    // Only log for terminal states to reduce noise
    if (viewModel.state == SmsIntegrationState.completed) {
      debugPrint('🔔 SMS Loading Screen - Listener fired! State: ${viewModel.state}');
      debugPrint('🎉 STATE IS COMPLETED - STARTING NAVIGATION');
      // Remove listener before navigating
      viewModel.removeListener(_onStateChanged);
      _navigateToHome();
    } else if (viewModel.state == SmsIntegrationState.error) {
      debugPrint('🔔 SMS Loading Screen - Listener fired! State: ${viewModel.state}');
      debugPrint('❌ STATE IS ERROR');
      // Remove listener before showing error
      viewModel.removeListener(_onStateChanged);
      
      // Show error dialog
      if (mounted) {
        _showErrorDialog(viewModel.errorMessage ?? 'An error occurred');
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    
    debugPrint('SMS Loading Screen - Navigating to home screen immediately');
    
    // Navigate immediately to prevent widget disposal issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.createWallet);
            },
            child: const Text('Continue Manually'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<SmsIntegrationViewModel>(
          builder: (context, viewModel, child) {
            // Check for completion in build method as a backup
            if (viewModel.state == SmsIntegrationState.completed) {
              debugPrint('🎯 Build detected completed state - scheduling navigation');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _navigateToHome();
                }
              });
            }
            
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary100,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.message_outlined,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Title
                  Text(
                    _getStateTitle(viewModel.state),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.blackPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Description
                  Text(
                    _getStateDescription(viewModel.state),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Progress indicator
                  if (viewModel.totalMessages > 0) ...[
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: viewModel.progress,
                        backgroundColor: AppColors.primary100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Progress text
                    Text(
                      '${viewModel.processedMessages} of ${viewModel.totalMessages} messages processed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ] else ...[
                    // Circular progress indicator
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Info text
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'This may take a few moments depending on your message history',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getStateTitle(SmsIntegrationState state) {
    switch (state) {
      case SmsIntegrationState.scanning:
        return 'Scanning Messages';
      case SmsIntegrationState.parsing:
        return 'Processing Transactions';
      case SmsIntegrationState.creatingWallets:
        return 'Creating Wallets';
      case SmsIntegrationState.completed:
        return 'All Done!';
      default:
        return 'Setting Up...';
    }
  }

  String _getStateDescription(SmsIntegrationState state) {
    switch (state) {
      case SmsIntegrationState.scanning:
        return 'Searching for Equity Bank and MTN MoMo messages';
      case SmsIntegrationState.parsing:
        return 'Extracting transaction details from your messages';
      case SmsIntegrationState.creatingWallets:
        return 'Setting up your wallets and importing transactions';
      case SmsIntegrationState.completed:
        return 'Your wallets have been created successfully!';
      default:
        return 'Please wait while we prepare your account';
    }
  }

  @override
  void dispose() {
    // Safely remove listener but DON'T dispose the ViewModel
    // The ViewModel is owned by the Provider and will be disposed when appropriate
    try {
      final viewModel = context.read<SmsIntegrationViewModel>();
      viewModel.removeListener(_onStateChanged);
      debugPrint('SMS Loading Screen - Listener removed in dispose');
    } catch (e) {
      debugPrint('SMS Loading Screen - Error removing listener: $e');
    }
    // Don't call super.dispose() on the ViewModel - let Provider handle it
    super.dispose();
  }
}
