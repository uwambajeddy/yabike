import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/notification_service.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/transaction_list_item.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Main home screen/dashboard matching the design
class HomeScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
      _loadUnreadCount();
    });
  }

  void _loadUnreadCount() {
    setState(() {
      _unreadCount = _notificationService.getUnreadCount();
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                iconSize: 28.0,
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.notificationInbox);
                  _loadUnreadCount(); // Refresh count after returning
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show snackbar when new transactions are imported
          if (viewModel.newTransactionsCount > 0 && !viewModel.isRefreshing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Imported ${viewModel.newTransactionsCount} new transaction${viewModel.newTransactionsCount > 1 ? 's' : ''}!',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
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

                  // Last 7 Days Chart
                  _buildLast7DaysChart(context, viewModel),
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
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNavigation() : null,
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

  Widget _buildLast7DaysChart(BuildContext context, HomeViewModel viewModel) {
    // Get last 7 days data
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    // Calculate income and expenses for each day
    final allTransactions = viewModel.getAllTransactionsForChart();

    Map<String, double> dailyIncome = {};
    Map<String, double> dailyExpenses = {};

    for (var day in last7Days) {
      final dateKey = DateFormat('yyyy-MM-dd').format(day);
      dailyIncome[dateKey] = 0;
      dailyExpenses[dateKey] = 0;
    }

    // Aggregate transactions
    for (var transaction in allTransactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (dailyIncome.containsKey(dateKey)) {
        if (transaction.type == 'credit') {
          dailyIncome[dateKey] = (dailyIncome[dateKey] ?? 0) + transaction.amount;
        } else {
          dailyExpenses[dateKey] = (dailyExpenses[dateKey] ?? 0) + transaction.amount;
        }
      }
    }

    // Find max value for scaling
    double maxValue = 0;
    for (var day in last7Days) {
      final dateKey = DateFormat('yyyy-MM-dd').format(day);
      final income = dailyIncome[dateKey] ?? 0;
      final expense = dailyExpenses[dateKey] ?? 0;
      if (income > maxValue) maxValue = income;
      if (expense > maxValue) maxValue = expense;
    }

    if (maxValue == 0) maxValue = 1000; // Default if no data

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last 7 days',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.transactions);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < 7) {
                          final day = last7Days[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('EEE').format(day).substring(0, 3),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final day = last7Days[index];
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final income = dailyIncome[dateKey] ?? 0;
                  final expense = dailyExpenses[dateKey] ?? 0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: AppColors.income,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: expense,
                        color: AppColors.expense,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.income,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Income',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Expenses',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader(BuildContext context, HomeViewModel viewModel) {
    final totalTransactions = viewModel.totalTransactionCount;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalTransactions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.transactions);
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
                  Navigator.pushNamed(
                    context,
                    AppRoutes.transactionDetail,
                    arguments: transaction,
                  );
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
    return Expanded(
      child: InkWell(
        onTap: () {
          if (label == 'Transactions') {
            Navigator.pushNamed(context, AppRoutes.transactions);
          }
          // TODO: Add navigation for Budget and Settings tabs
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
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : Colors.grey,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
