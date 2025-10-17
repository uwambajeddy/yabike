import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/widgets/transaction_list_item.dart';
import '../viewmodels/transactions_viewmodel.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final bool showBottomNav;

  const TransactionsScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedDateRange = 'All Time';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.showBottomNav
            ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Transaction Recap',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.filter_list, color: Colors.black, size: 20),
            ),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showSearch ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                border: Border.all(
                  color: _showSearch ? AppColors.primary : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.search,
                color: _showSearch ? AppColors.primary : Colors.black,
                size: 20,
              ),
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  context.read<TransactionsViewModel>().setSearch('');
                }
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<TransactionsViewModel>(
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
                          '✨ Imported ${viewModel.newTransactionsCount} new transaction${viewModel.newTransactionsCount > 1 ? 's' : ''}!',
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
                  // Search bar
                  if (_showSearch) ...[
                    _buildSearchBar(viewModel),
                    const SizedBox(height: 16),
                  ],

                  // Active filters chips
                  if (viewModel.hasActiveFilters) ...[
                    _buildActiveFiltersChips(viewModel),
                    const SizedBox(height: 16),
                  ],

                  // Date range selector
                  _buildDateRangeSelector(viewModel),
                  const SizedBox(height: 16),

                  // Net Balance Card
                  _buildNetBalanceCard(viewModel),
                  const SizedBox(height: 16),

                  // Income/Expenses Cards
                  _buildIncomeExpenseCards(viewModel),
                  const SizedBox(height: 24),

                  // Transaction List
                  _buildTransactionList(viewModel),

                  const SizedBox(height: 24),

                  // Categories Section
                  _buildCategoriesSection(viewModel),

                  const SizedBox(height: 24),

                  // Rank Section
                  _buildRankSection(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeSelector(TransactionsViewModel viewModel) {
    final dateRanges = [
      {'label': 'All Time', 'value': 'all'},
      {'label': 'Today', 'value': 'today'},
      {'label': 'This Week', 'value': 'week'},
      {'label': 'This Month', 'value': 'month'},
      {'label': 'This Year', 'value': 'year'},
      {'label': 'Custom', 'value': 'custom'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dateRanges.map((range) {
          final isSelected = _selectedDateRange == range['label'];
          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedDateRange = range['label'] as String;
              });

              // Apply date range filter
              if (range['value'] == 'today') {
                final today = DateTime.now();
                final start = DateTime(today.year, today.month, today.day);
                final end = DateTime(today.year, today.month, today.day, 23, 59, 59);
                viewModel.setDateRangeFilter(start, end);
              } else if (range['value'] == 'week') {
                final now = DateTime.now();
                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
                final end = DateTime.now();
                viewModel.setDateRangeFilter(start, end);
              } else if (range['value'] == 'month') {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, 1);
                final end = DateTime.now();
                viewModel.setDateRangeFilter(start, end);
              } else if (range['value'] == 'year') {
                final now = DateTime.now();
                final start = DateTime(now.year, 1, 1);
                final end = DateTime.now();
                viewModel.setDateRangeFilter(start, end);
              } else if (range['value'] == 'all') {
                viewModel.setDateRangeFilter(null, null);
              } else if (range['value'] == 'custom') {
                // Show custom date range picker
                await _showCustomDateRangePicker(context, viewModel);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              child: Text(
                range['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showCustomDateRangePicker(BuildContext context, TransactionsViewModel viewModel) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: viewModel.startDate != null && viewModel.endDate != null
          ? DateTimeRange(start: viewModel.startDate!, end: viewModel.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.setDateRangeFilter(picked.start, picked.end);
      setState(() {
        _selectedDateRange = '${DateFormat('MMM d').format(picked.start)} - ${DateFormat('MMM d').format(picked.end)}';
      });
    }
  }

  Widget _buildNetBalanceCard(TransactionsViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net Balance: ${viewModel.currency}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${viewModel.currency} ${_formatAmount(viewModel.netBalance)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.income,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCards(TransactionsViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
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
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${viewModel.currency} ${_formatAmount(viewModel.totalIncome)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
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
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${viewModel.currency} ${_formatAmount(viewModel.totalExpenses)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(TransactionsViewModel viewModel) {
    if (viewModel.transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No transactions yet'),
        ),
      );
    }

    final grouped = viewModel.groupedTransactions;
    final dateKeys = grouped.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Transaction List',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
                '${viewModel.transactions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Grouped transactions by date with ListView.builder
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dateKeys.length,
          itemBuilder: (context, index) {
            final dateKey = dateKeys[index];
            final transactions = grouped[dateKey]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: Text(
                    dateKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Transactions for this date
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, txIndex) {
                    final transaction = transactions[txIndex];
                    return TransactionListItem(
                      transaction: transaction,
                      walletName: viewModel.getWalletName(transaction.walletId),
                      emoji: viewModel.getTransactionEmoji(transaction.id),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.transactionDetail,
                          arguments: transaction,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(TransactionsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // Pie chart placeholder
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'Chart',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankSection(TransactionsViewModel viewModel) {
    final categoryStats = viewModel.getCategoryStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rank',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Income section
          const Text(
            'Income',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...categoryStats['income']!.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return _buildRankItem(
              index + 1,
              stat['category'] as String,
              stat['percentage'] as double,
              AppColors.income,
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Expenses section
          const Text(
            'Expenses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...categoryStats['expenses']!.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return _buildRankItem(
              index + 1,
              stat['category'] as String,
              stat['percentage'] as double,
              stat['color'] as Color,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRankItem(int rank, String category, double percentage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '$rank. ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            '${percentage.toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  Widget _buildSearchBar(TransactionsViewModel viewModel) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  viewModel.setSearch('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onChanged: (value) {
        viewModel.setSearch(value);
      },
    );
  }

  Widget _buildActiveFiltersChips(TransactionsViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (viewModel.selectedWalletId != null)
          _buildFilterChip(
            'Wallet: ${viewModel.wallets.firstWhere((w) => w.id == viewModel.selectedWalletId).name}',
            () => viewModel.setWalletFilter(null),
          ),
        if (viewModel.selectedCategory != null)
          _buildFilterChip(
            'Category: ${viewModel.selectedCategory}',
            () => viewModel.setCategoryFilter(null),
          ),
        if (viewModel.selectedType != null)
          _buildFilterChip(
            viewModel.selectedType == 'credit' ? 'Income' : 'Expenses',
            () => viewModel.setTypeFilter(null),
          ),
        if (viewModel.startDate != null || viewModel.endDate != null)
          _buildFilterChip(
            'Date Range',
            () => viewModel.setDateRangeFilter(null, null),
          ),
        if (viewModel.hasActiveFilters)
          TextButton.icon(
            onPressed: () => viewModel.clearFilters(),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDelete,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final viewModel = context.read<TransactionsViewModel>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters & Sort',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort by
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSortOptionsModal(viewModel, setModalState),
                      
                      const SizedBox(height: 24),
                      
                      // Filter by wallet
                      const Text(
                        'Wallet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWalletFilterModal(viewModel, setModalState),
                      
                      const SizedBox(height: 24),
                      
                      // Filter by type
                      const Text(
                        'Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTypeFilterModal(viewModel, setModalState),
                      
                      const SizedBox(height: 24),
                      
                      // Filter by category
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryFilterModal(viewModel, setModalState),
                    ],
                  ),
                ),
              ),
              
              // Apply button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          viewModel.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptionsModal(TransactionsViewModel viewModel, StateSetter setModalState) {
    return Column(
      children: [
        _buildSortOptionModal(viewModel, setModalState, SortBy.dateNewest, 'Newest First'),
        _buildSortOptionModal(viewModel, setModalState, SortBy.dateOldest, 'Oldest First'),
        _buildSortOptionModal(viewModel, setModalState, SortBy.amountHighest, 'Highest Amount'),
        _buildSortOptionModal(viewModel, setModalState, SortBy.amountLowest, 'Lowest Amount'),
        _buildSortOptionModal(viewModel, setModalState, SortBy.category, 'Category'),
      ],
    );
  }

  Widget _buildSortOptionModal(TransactionsViewModel viewModel, StateSetter setModalState, SortBy sortBy, String label) {
    return RadioListTile<SortBy>(
      value: sortBy,
      groupValue: viewModel.sortBy,
      title: Text(label),
      activeColor: AppColors.primary,
      onChanged: (value) {
        if (value != null) {
          setModalState(() {
            viewModel.setSortBy(value);
          });
        }
      },
    );
  }

  Widget _buildWalletFilterModal(TransactionsViewModel viewModel, StateSetter setModalState) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterOptionChipModal(
          'All Wallets',
          viewModel.selectedWalletId == null,
          () {
            setModalState(() {
              viewModel.setWalletFilter(null);
            });
          },
        ),
        ...viewModel.wallets.map((wallet) {
          return _buildFilterOptionChipModal(
            wallet.name,
            viewModel.selectedWalletId == wallet.id,
            () {
              setModalState(() {
                viewModel.setWalletFilter(wallet.id);
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTypeFilterModal(TransactionsViewModel viewModel, StateSetter setModalState) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterOptionChipModal(
          'All',
          viewModel.selectedType == null,
          () {
            setModalState(() {
              viewModel.setTypeFilter(null);
            });
          },
        ),
        _buildFilterOptionChipModal(
          'Income',
          viewModel.selectedType == 'credit',
          () {
            setModalState(() {
              viewModel.setTypeFilter('credit');
            });
          },
        ),
        _buildFilterOptionChipModal(
          'Expenses',
          viewModel.selectedType == 'debit',
          () {
            setModalState(() {
              viewModel.setTypeFilter('debit');
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryFilterModal(TransactionsViewModel viewModel, StateSetter setModalState) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterOptionChipModal(
          'All Categories',
          viewModel.selectedCategory == null,
          () {
            setModalState(() {
              viewModel.setCategoryFilter(null);
            });
          },
        ),
        ...viewModel.categories.map((category) {
          return _buildFilterOptionChipModal(
            category,
            viewModel.selectedCategory == category,
            () {
              setModalState(() {
                viewModel.setCategoryFilter(category);
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFilterOptionChipModal(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
