import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/step_header.dart';
import '../widgets/budget_text_field.dart';

class BudgetNameStep extends StatelessWidget {
  final TextEditingController nameController;

  const BudgetNameStep({
    super.key,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          step: 'Step 1',
          title: 'Name Your Spending Budget',
          description: 'Set a limit on how much you want to spend',
        ),
        const SizedBox(height: 24),
        
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Budgets help you control spending by category. Your spending will be automatically tracked from transactions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Name Input
        BudgetTextField(
          controller: nameController,
          label: 'Budget Name',
          hint: 'e.g., Monthly Groceries, Weekly Transport',
          icon: Icons.label_outline,
          autofocus: true,
        ),
      ],
    );
  }
}
