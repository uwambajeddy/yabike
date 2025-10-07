import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../viewmodels/create_wallet_viewmodel.dart';
import '../../../core/routes/app_routes.dart';

/// Success screen after wallet creation
class WalletSuccessScreen extends StatefulWidget {
  const WalletSuccessScreen({super.key});

  @override
  State<WalletSuccessScreen> createState() => _WalletSuccessScreenState();
}

class _WalletSuccessScreenState extends State<WalletSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final viewModel = context.read<CreateWalletViewModel>();
    
    // TODO: Save wallet to database
    // final wallet = viewModel.createWallet();
    
    // Reset viewmodel
    viewModel.reset();
    
    // Navigate to home
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateWalletViewModel>();
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Success icon with animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: AppSpacing.xxl),
              
              // Success title
              Text(
                'Wallet Created!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Wallet details
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Wallet Name',
                      viewModel.walletName,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _buildDetailRow(
                      'Currency',
                      '${viewModel.selectedCurrency.code} (${viewModel.selectedCurrency.symbol})',
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _buildDetailRow(
                      'Initial Balance',
                      '${viewModel.selectedCurrency.symbol} ${viewModel.initialBalance.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: const Text('Go to Dashboard'),
                ),
              ),
              
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
