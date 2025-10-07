import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../viewmodels/create_wallet_viewmodel.dart';
import '../widgets/calculator_widget.dart';
import 'wallet_success_screen.dart';

/// Screen for entering wallet initial balance with calculator
class WalletBalanceScreen extends StatefulWidget {
  const WalletBalanceScreen({super.key});

  @override
  State<WalletBalanceScreen> createState() => _WalletBalanceScreenState();
}

class _WalletBalanceScreenState extends State<WalletBalanceScreen> {
  String _displayValue = '0';
  
  void _onNumberPressed(String number) {
    setState(() {
      if (_displayValue == '0') {
        _displayValue = number;
      } else {
        _displayValue += number;
      }
    });
  }

  void _onDecimalPressed() {
    if (!_displayValue.contains('.')) {
      setState(() {
        _displayValue += '.';
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _displayValue = '0';
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_displayValue.length > 1) {
        _displayValue = _displayValue.substring(0, _displayValue.length - 1);
      } else {
        _displayValue = '0';
      }
    });
  }

  void _continue() {
    final viewModel = context.read<CreateWalletViewModel>();
    final balance = double.tryParse(_displayValue) ?? 0.0;
    viewModel.setInitialBalance(balance);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: const WalletSuccessScreen(),
        ),
      ),
    );
  }

  void _skip() {
    final viewModel = context.read<CreateWalletViewModel>();
    viewModel.setInitialBalance(0.0);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: const WalletSuccessScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateWalletViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initial Balance'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header info
            Padding(
              padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Starting Balance',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'How much money is currently in this wallet?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.xl),
            
            // Display amount
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  Text(
                    viewModel.selectedCurrency.symbol,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    _displayValue,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Calculator
            CalculatorWidget(
              onNumberPressed: _onNumberPressed,
              onDecimalPressed: _onDecimalPressed,
              onClearPressed: _onClearPressed,
              onBackspacePressed: _onBackspacePressed,
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Continue button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: const Text('Continue'),
                ),
              ),
            ),
            
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
