import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/step_header.dart';
import '../widgets/budget_date_field.dart';
import '../widgets/budget_duration_info.dart';

class BudgetDateStep extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateSelected;
  final ValueChanged<DateTime> onEndDateSelected;

  const BudgetDateStep({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          step: 'Step 4',
          title: 'Set Budget Period',
          description: 'Choose when this spending limit applies',
        ),
        const SizedBox(height: 32),
        
        // Illustration
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 40),
        
        // Start Date
        BudgetDateField(
          label: 'Start Date',
          date: startDate,
          icon: Icons.calendar_today,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onStartDateSelected(date);
            }
          },
        ),
        const SizedBox(height: 20),
        
        // End Date
        BudgetDateField(
          label: 'End Date',
          date: endDate,
          icon: Icons.event,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: endDate ?? (startDate?.add(const Duration(days: 30)) ?? DateTime.now()),
              firstDate: startDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onEndDateSelected(date);
            }
          },
        ),
        
        if (startDate != null && endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: BudgetDurationInfo(
              startDate: startDate!,
              endDate: endDate!,
            ),
          ),
      ],
    );
  }
}
