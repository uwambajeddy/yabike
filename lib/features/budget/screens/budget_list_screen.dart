import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/budget_viewmodel.dart';
import 'create_budget_screen.dart';
import 'budget_detail_screen.dart';

/// Screen showing spending budget limits
class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Budgeting', style: theme.appBarTheme.titleTextStyle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              // TODO: Export budgets functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search budgets functionality
            },
          ),
        ],
      ),
      body: Consumer<BudgetViewModel>(
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
                // Info banner
                _buildInfoBanner(context),
                const SizedBox(height: 24),

                // Section title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spending Budgets',
                      style: theme.textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: () => _createNewBudget(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Budget list or empty state
                if (viewModel.hasBudgets)
                  _buildBudgetList(viewModel)
                else
                  _buildEmptyState(context),
              ],
            ),
          ),
        );
      },
    ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5FCDC), // Light green background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Piggy bank illustration
               SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              'assets/images/budget-planner-and-money.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 20),
          
          // Text and button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Text(
                  'Visualize Your Finances!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF2D6A4F),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _createNewBudget(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create a Budget Today'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD966),
                    foregroundColor: const Color(0xFF2D6A4F),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: theme.textTheme.labelMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Piggy bank with question marks 
            Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5FCDC),
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(
                Icons.savings,
                size: 64,
                color: AppColors.primary,
              ),
              Positioned(
                top: 0,
                right: 20,
                child: Text(
                  '??',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'You don\'t have any budgets at the moment.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline, 
                size: 16, 
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Try clicking the button above,\nor click here to create a new one.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList(BudgetViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.budgets.length,
      itemBuilder: (context, index) {
        final budget = viewModel.budgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  Widget _buildBudgetCard(budget) {
    final theme = Theme.of(context);
    
    Color getStatusColor() {
      if (budget.isExceeded || budget.percentageUsed >= 100) return AppColors.error;
      if (budget.percentageUsed >= 80) return AppColors.warning;
      if (budget.percentageUsed >= 60) return AppColors.budgetWarning;
      return AppColors.success;
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

    return InkWell(
      onTap: () async {
        final budgetViewModel = context.read<BudgetViewModel>();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: budgetViewModel,
              child: BudgetDetailScreen(budget: budget),
            ),
          ),
        );
        if (result == true && mounted) {
          budgetViewModel.initialize();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, name, and menu
            Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getCategoryIcon(),
                    color: getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Budget name
                Expanded(
                  child: Text(
                    budget.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Menu button
                Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total Amount Spent label and amount
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
                  // Use a softer yellow for warning state to match design
                  final Color fillColor = getStatusColor() == AppColors.warning
                      ? AppColors.softYellow
                      : getStatusColor();
                  const Color bgColor = Color(0xFFE8F5E9);

                  // Determine if center of bar is over the filled area
                  final bool centerOverFill = fill >= 0.5;

                  // Pick readable text color based on which area the center sits on
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
            
            // Footer with time remaining, end date, and category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${budget.daysRemaining} days',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievement Date',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(budget.endDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Category',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      budget.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  Future<void> _createNewBudget(BuildContext context) async {
    final existingViewModel = context.read<BudgetViewModel>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: existingViewModel,
          child: const CreateBudgetStepperScreen(),
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<BudgetViewModel>().initialize();
    }
  }
}
