import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../viewmodels/budget_viewmodel.dart';
import '../../transaction/screens/transactions_screen.dart';
import '../../transaction/screens/add_transaction_screen.dart';
import '../../transaction/viewmodels/transactions_viewmodel.dart';
import '../../transaction/viewmodels/add_transaction_viewmodel.dart';
import 'create_budget_screen.dart';

class BudgetDetailScreen extends StatelessWidget {
  final Budget budget;

  const BudgetDetailScreen({
    super.key,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.whiteTertiary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Spending Budget Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert, color: AppColors.textPrimary, size: 20),
            ),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            const SizedBox(height: 16),

            // Add Funds / Withdraw Buttons
            _buildActionButtons(context),

            const SizedBox(height: 24),

            // Fund Progress Card
            _buildFundProgress(context),

            const SizedBox(height: 24),

            // More Details Card
            _buildMoreDetails(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    Color getStatusColor() {
      if (budget.isExceeded || budget.percentageUsed >= 100) return AppColors.budgetCritical;
      if (budget.percentageUsed >= 80) return AppColors.warning;
      if (budget.percentageUsed >= 60) return AppColors.budgetWarning;
      return AppColors.primary;
    }

    IconData getCategoryIcon() {
      final categoryLower = budget.category.toLowerCase();
      if (categoryLower.contains('education') || categoryLower.contains('school')) {
        return Icons.school;
      } else if (categoryLower.contains('food') || categoryLower.contains('dining')) {
        return Icons.restaurant;
      } else if (categoryLower.contains('transport')) {
        return Icons.directions_car;
      } else if (categoryLower.contains('shopping')) {
        return Icons.shopping_bag;
      } else if (categoryLower.contains('health')) {
        return Icons.local_hospital;
      } else if (categoryLower.contains('entertainment')) {
        return Icons.movie;
      } else if (categoryLower.contains('travel')) {
        return Icons.flight;
      }
      return Icons.category;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          // Category Icon with shadow
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: getStatusColor().withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getCategoryIcon(),
                size: 42,
                color: getStatusColor(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Category with badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: getStatusColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              budget.category.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: getStatusColor(),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Budget Name
          Text(
            budget.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Time remaining badge
          if (budget.daysRemaining >= 0)
            Text(
              '${budget.daysRemaining} days remaining',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              'Expired ${-budget.daysRemaining} days ago',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.budgetCritical,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to add transaction with pre-filled category
                _showAddExpenseOptions(context);
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Add Expense'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to transactions screen filtered by budget category
                _viewTransactionHistory(context);
              },
              icon: const Icon(Icons.receipt_long_outlined, size: 20),
              label: const Text('View History'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundProgress(BuildContext context) {
    final theme = Theme.of(context);

    Color getStatusColor() {
      if (budget.isExceeded || budget.percentageUsed >= 100) return AppColors.budgetCritical;
      if (budget.percentageUsed >= 80) return AppColors.warning;
      if (budget.percentageUsed >= 60) return AppColors.budgetWarning;
      return AppColors.primary;
    }

    String getProgressMessage() {
      final remaining = budget.amount - budget.spent;
      if (budget.isExceeded) {
        return 'You have exceeded your budget by Rwf ${_formatAmount(budget.spent - budget.amount)}';
      } else {
        return 'Keep going! You have Rwf ${_formatAmount(remaining)} remaining to stay within budget';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Title
                Text(
                  'Spending Progress',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Amount display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount Spent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rwf ${_formatAmount(budget.spent)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: getStatusColor(),
                          ),
                        ),
                        Text(
                          '/Rwf ${_formatAmount(budget.amount)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress bar with percentage always centered
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Builder(
                    builder: (context) {
                      final fill = (budget.percentageUsed / 100).clamp(0.0, 1.0);
                      final Color fillColor = getStatusColor() == AppColors.warning
                          ? AppColors.softYellow
                          : getStatusColor();
                      const Color bgColor = Color(0xFFE8F5E9);

                      final bool centerOverFill = fill >= 0.5;
                      Color contrastColor(Color c) => c.computeLuminance() < 0.5 ? Colors.white : Colors.black87;
                      final textColor = centerOverFill ? contrastColor(fillColor) : contrastColor(bgColor);

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background bar
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Filled portion
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: fill,
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          // Percentage text always centered with adaptive contrast
                          Text(
                            '${budget.percentageUsed.toStringAsFixed(0)}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Progress message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteTertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          getProgressMessage(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Details Grid with icons
          _buildDetailRow(Icons.category_outlined, 'Category', budget.category),
          const Divider(height: 32),
          _buildDetailRow(Icons.attach_money, 'Budget Limit', 'Rwf ${_formatAmount(budget.amount)}'),
          const Divider(height: 32),
          _buildDetailRow(Icons.wallet_outlined, 'Total Spent', 'Rwf ${_formatAmount(budget.spent)}'),
          const Divider(height: 32),
          _buildDetailRow(
            Icons.event_outlined,
            'End Date',
            DateFormat('dd MMM yyyy').format(budget.endDate),
          ),
          const Divider(height: 32),
          _buildDetailRow(
            Icons.access_time, 
            'Days Left', 
            budget.daysRemaining >= 0 
              ? '${budget.daysRemaining} days' 
              : 'Expired',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  void _showOptionsMenu(BuildContext context) {
    final budgetViewModel = context.read<BudgetViewModel>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => ChangeNotifierProvider.value(
        value: budgetViewModel,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Budget'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  // Navigate to edit budget screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => BudgetViewModel()..setEditingBudget(budget),
                        child: const CreateBudgetStepperScreen(isEditing: true),
                      ),
                    ),
                  );
                  // Refresh and close if budget was updated
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Budget', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final viewModel = context.read<BudgetViewModel>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await viewModel.deleteBudget(budget.id);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context, true); // Return to list with refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete budget: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Add Expense to ${budget.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              title: const Text('Create New Transaction'),
              subtitle: Text('Category: ${budget.category}'),
              onTap: () async {
                Navigator.pop(context);
                // Navigate to create transaction screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) {
                        final viewModel = AddTransactionViewModel();
                        viewModel.initialize().then((_) {
                          // Set transaction type to expense
                          viewModel.setType(TransactionType.expense);
                          
                          // Find and set the category after initialization
                          final expenseCategories = viewModel.categories.where((c) => c.type == CategoryType.expense).toList();
                          if (expenseCategories.isNotEmpty) {
                            final matchingCategory = expenseCategories.firstWhere(
                              (cat) => cat.name.toLowerCase() == budget.category.toLowerCase(),
                              orElse: () => expenseCategories.first,
                            );
                            viewModel.setCategory(matchingCategory);
                          }
                        });
                        return viewModel;
                      },
                      child: const AddTransactionScreen(),
                    ),
                  ),
                );
                // Refresh budget data if transaction was created
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.primary),
              title: const Text('Import from SMS'),
              subtitle: const Text('Import recent transactions'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to SMS import with category filter
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SMS import feature coming soon'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewTransactionHistory(BuildContext context) {
    // Navigate to transactions screen with category and date range filters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) {
            final viewModel = TransactionsViewModel();
            viewModel.initialize().then((_) {
              // Set category filter
              viewModel.setCategoryFilter(budget.category);
              // Set date range filter to match budget period
              viewModel.setDateRangeFilter(budget.startDate, budget.endDate);
            });
            return viewModel;
          },
          child: const TransactionsScreen(showBottomNav: false),
        ),
      ),
    );
  }
}
