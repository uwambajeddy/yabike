import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/step_header.dart';
import '../widgets/budget_amount_field.dart';
import '../widgets/budget_period_card.dart';

class BudgetAmountStep extends StatelessWidget {
  final TextEditingController amountController;
  final List<Map<String, dynamic>> periods;
  final String? selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const BudgetAmountStep({
    super.key,
    required this.amountController,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          step: 'Step 3',
          title: 'Set Spending Limit',
          description: 'How much can you spend in this category?',
        ),
        const SizedBox(height: 24),
        
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You\'ll be notified when you reach 80% of this limit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Amount Input with Currency
        BudgetAmountField(controller: amountController),
        const SizedBox(height: 32),
        
        // Period Selection
        Text(
          'Select Period',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: periods.length,
          itemBuilder: (context, index) {
            final period = periods[index];
            final isSelected = selectedPeriod == period['name'];
            
            return BudgetPeriodCard(
              name: period['name'],
              icon: period['icon'],
              isSelected: isSelected,
              onTap: () => onPeriodSelected(period['name']),
            );
          },
        ),
      ],
    );
  }
}
