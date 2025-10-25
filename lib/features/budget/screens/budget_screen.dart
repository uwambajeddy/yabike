import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/budget_viewmodel.dart';
import 'create_budget_screen.dart';
import 'budget_detail_screen.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
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
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Budgeting', style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_chart, 
                color: colorScheme.onSurface, 
                size: 20,
              ),
            ),
            onPressed: () async {
              final existingViewModel = context.read<BudgetViewModel>();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListenableProvider.value(
                    value: existingViewModel,
                    child: const CreateBudgetStepperScreen(),
                  ),
                ),
              );
              if (result == true && mounted) {
                context.read<BudgetViewModel>().initialize();
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.search, 
                color: colorScheme.onSurface, 
                size: 20,
              ),
            ),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          const SizedBox(width: 16),
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
                  // Banner
                  _buildBanner(context),
                  const SizedBox(height: 24),

                  // Your Budget Section
                  Text(
                    'Your Budget',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Budget List or Empty State
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

  Widget _buildBanner(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5FCDC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
                  onPressed: () async {
                    final existingViewModel = context.read<BudgetViewModel>();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListenableProvider.value(
                          value: existingViewModel,
                          child: const CreateBudgetStepperScreen(),
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      context.read<BudgetViewModel>().initialize();
                    }
                  },
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Piggy bank with question marks
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
            'You don\'t have any budget at the moment.',
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
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBudgetList(BudgetViewModel viewModel) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.budgets.length,
          itemBuilder: (context, index) {
            final budget = viewModel.budgets[index];
            return _buildBudgetCard(budget);
          },
        ),
        const SizedBox(height: 8),
        _buildCreateBudgetButton(context),
      ],
    );
  }

  Widget _buildCreateBudgetButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () async {
        final existingViewModel = context.read<BudgetViewModel>();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListenableProvider.value(
              value: existingViewModel,
              child: const CreateBudgetStepperScreen(),
            ),
          ),
        );
        if (result == true && mounted) {
          context.read<BudgetViewModel>().initialize();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: DashedBorder(
        color: AppColors.primary,
        strokeWidth: 2,
        dashLength: 8,
        gapLength: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Create new budget',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(budget) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color getStatusColor() {
      if (budget.isExceeded) return AppColors.budgetCritical;
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

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetDetailScreen(budget: budget),
          ),
        );
        if (result == true && mounted) {
          context.read<BudgetViewModel>().initialize();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
            // Header with icon and menu
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
            
            // Total funds saved and amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'The Total Funds Saved',
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
            
            // Progress bar
            Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (budget.percentageUsed / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${budget.percentageUsed.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Footer with time remaining and category
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
}

// Custom Dashed Border Widget
class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.gapLength = 3,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);

    path.addRRect(rrect);

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = distance + dashLength;
        final segment = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        canvas.drawPath(segment, paint);
        distance = nextDistance + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
