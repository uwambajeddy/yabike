import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/wallet_model.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/transaction_list_item.dart';

/// Main home screen/dashboard matching the design
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            // App logo
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 5)),
            Text(AppStrings.homeTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            iconSize: 28.0,
            onPressed: () {
              // TODO: Open notifications
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Net Balance Card
                  _buildNetBalanceCard(context, viewModel),
                  const SizedBox(height: 16),

                  // Income/Expenses Row
                  _buildIncomeExpenseCards(context, viewModel),
                  const SizedBox(height: 24),

                  // Transaction Section Header
                  _buildTransactionHeader(context, viewModel),
                  const SizedBox(height: 12),

                  // Transactions List
                  _buildTransactionsList(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNetBalanceCard(BuildContext context, HomeViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet selector
          if (viewModel.hasWallets)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButton<Wallet?>(
                value: viewModel.selectedWallet,
                isDense: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.primary,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                items: [
                  const DropdownMenuItem<Wallet?>(
                    value: null,
                    child: Text('All Wallets', style: TextStyle(color: Colors.white)),
                  ),
                  ...viewModel.wallets.map((wallet) {
                    return DropdownMenuItem<Wallet?>(
                      value: wallet,
                      child: Row(
                        children: [
                          Icon(
                            wallet.type == 'bank' ? Icons.account_balance : Icons.account_balance_wallet,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(wallet.name, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (wallet) {
                  viewModel.selectWallet(wallet);
                },
              ),
            ),
          const SizedBox(height: 16),
          Text(
            viewModel.selectedWallet != null 
                ? '${viewModel.selectedWallet!.name} Balance'
                : 'Net Balance',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.getFormattedBalance(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCards(BuildContext context, HomeViewModel viewModel) {
    return Row(
      children: [
        // Income Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.income,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Income',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.getFormattedIncome(),
                  style: const TextStyle(
                    color: AppColors.income,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Expenses Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.expense,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Expenses',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.getFormattedExpenses(),
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHeader(BuildContext context, HomeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transaction',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to all transactions
          },
          child: const Text(
            'See More',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(BuildContext context, HomeViewModel viewModel) {
    if (!viewModel.hasTransactions) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = viewModel.groupedTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Transactions for this date
            ...entry.value.map((transaction) {
              final walletId = transaction.walletId;
              return TransactionListItem(
                transaction: transaction,
                walletName: walletId != null && walletId.isNotEmpty
                    ? viewModel.getWalletName(walletId)
                    : null,
                onTap: () {
                  // TODO: Navigate to transaction detail
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.receipt_long, 'Transactions', false),
              _buildAddButton(),
              _buildNavItem(Icons.pie_chart, 'Budget', false),
              _buildNavItem(Icons.settings, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {
        // TODO: Navigate
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () async {
        // Navigate to add transaction and refresh on return
        await Navigator.pushNamed(context, AppRoutes.addTransaction);
        if (mounted) {
          context.read<HomeViewModel>().refresh();
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
