import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../viewmodels/create_wallet_viewmodel.dart';
import 'currency_selection_screen.dart';

/// Screen for entering wallet name
class WalletNameScreen extends StatefulWidget {
  const WalletNameScreen({super.key});

  @override
  State<WalletNameScreen> createState() => _WalletNameScreenState();
}

class _WalletNameScreenState extends State<WalletNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _continue() {
    final viewModel = context.read<CreateWalletViewModel>();
    viewModel.setWalletName(_nameController.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: const CurrencySelectionScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createWallet),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              navigator.pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.xl),
              
              // Title
              Text(
                'Name Your Wallet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // Subtitle
              Text(
                'Give your wallet a memorable name',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              
              SizedBox(height: AppSpacing.xxl),
              
              // Wallet name input
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: AppStrings.walletName,
                  hintText: 'e.g., Main Wallet, Savings, etc.',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {}); // Rebuild to update button state
                },
                onSubmitted: (value) {
                  if (_nameController.text.trim().isNotEmpty) {
                    _continue();
                  }
                },
              ),
              
              const Spacer(),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().isEmpty
                      ? null
                      : _continue,
                  child: const Text(AppStrings.continueText),
                ),
              ),
              
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
