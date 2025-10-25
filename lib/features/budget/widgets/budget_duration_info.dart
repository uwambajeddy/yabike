import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BudgetDurationInfo extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const BudgetDurationInfo({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final days = endDate.difference(startDate).inDays;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This budget will run for $days days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
