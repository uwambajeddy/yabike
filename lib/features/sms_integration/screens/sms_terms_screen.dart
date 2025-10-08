import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../viewmodels/sms_integration_viewmodel.dart';
import 'package:provider/provider.dart';

class SmsTermsScreen extends StatefulWidget {
  const SmsTermsScreen({super.key});

  @override
  State<SmsTermsScreen> createState() => _SmsTermsScreenState();
}

class _SmsTermsScreenState extends State<SmsTermsScreen> {
  bool _hasAccepted = false;

  @override
  void initState() {
    super.initState();
    // Listen for completion and navigate to home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SmsIntegrationViewModel>();
      viewModel.addListener(_onStateChanged);
    });
  }

  void _onStateChanged() {
    final viewModel = context.read<SmsIntegrationViewModel>();
    
    if (viewModel.state == SmsIntegrationState.completed) {
      debugPrint('✅ SMS import completed - navigating to home');
      viewModel.removeListener(_onStateChanged);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (viewModel.state == SmsIntegrationState.error) {
      debugPrint('❌ SMS import error: ${viewModel.errorMessage}');
      // Don't navigate, just show error in the UI
    }
  }

  @override
  void dispose() {
    try {
      final viewModel = context.read<SmsIntegrationViewModel>();
      viewModel.removeListener(_onStateChanged);
    } catch (e) {
      // Ignore if already disposed
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmsIntegrationViewModel>(
      builder: (context, viewModel, child) {
        // Show loading overlay when scanning/processing
        final isLoading = viewModel.state == SmsIntegrationState.scanning ||
            viewModel.state == SmsIntegrationState.parsing ||
            viewModel.state == SmsIntegrationState.creatingWallets;

        return Stack(
          children: [
            Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'SMS Access Permission',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.blackPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Subtitle
              Text(
                'To automatically create your wallets and import transactions, YaBike needs access to your SMS messages.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Terms content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        context,
                        icon: Icons.message_outlined,
                        title: 'What we access',
                        content:
                            'YaBike will read SMS messages from your financial service providers (Equity Bank, MTN Mobile Money) to automatically create wallets and import your transaction history.',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      _buildSection(
                        context,
                        icon: Icons.security_outlined,
                        title: 'Your privacy matters',
                        content:
                            'All SMS data is processed locally on your device. We never send your messages to external servers. Your transaction data is encrypted and stored securely on your device only.',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      _buildSection(
                        context,
                        icon: Icons.auto_awesome_outlined,
                        title: 'What happens next',
                        content:
                            'After granting permission:\n'
                            '• We\'ll scan for Equity Bank and MTN MoMo messages\n'
                            '• Create a wallet for each service automatically\n'
                            '• Import your transaction history\n'
                            '• You\'ll be ready to track your finances!',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      _buildSection(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'You\'re in control',
                        content:
                            'You can revoke SMS access anytime from your device settings. Your imported transactions will remain available in the app.',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasAccepted = !_hasAccepted;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _hasAccepted ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: _hasAccepted
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _hasAccepted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'I agree to grant YaBike access to my SMS messages',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_hasAccepted && !isLoading)
                      ? () async {
                          final viewModel = context.read<SmsIntegrationViewModel>();
                          await viewModel.requestSmsPermission(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _hasAccepted ? Colors.white : AppColors.textDisabled,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                ),
              ),
            ],
          ),
        ),
              ),
            ),
            // Loading overlay
            if (isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            _getLoadingMessage(viewModel.state),
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            '${viewModel.processedMessages} of ${viewModel.totalMessages} messages processed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getLoadingMessage(SmsIntegrationState state) {
    switch (state) {
      case SmsIntegrationState.scanning:
        return 'Scanning SMS messages...';
      case SmsIntegrationState.parsing:
        return 'Processing transactions...';
      case SmsIntegrationState.creatingWallets:
        return 'Creating wallets...';
      default:
        return 'Please wait...';
    }
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.blackPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
