import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Custom calculator widget for number input
class CalculatorWidget extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onDecimalPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onBackspacePressed;

  const CalculatorWidget({
    super.key,
    required this.onNumberPressed,
    required this.onDecimalPressed,
    required this.onClearPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            children: [
              _buildNumberButton('1'),
              SizedBox(width: AppSpacing.md),
              _buildNumberButton('2'),
              SizedBox(width: AppSpacing.md),
              _buildNumberButton('3'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          // Row 2: 4, 5, 6
          Row(
            children: [
              _buildNumberButton('4'),
              SizedBox(width: AppSpacing.md),
              _buildNumberButton('5'),
              SizedBox(width: AppSpacing.md),
              _buildNumberButton('6'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          // Row 3: 7, 8, 9
          Row(
            children: [
              _buildNumberButton('7'),
              SizedBox(width: AppSpacing.md),
              _buildNumberButton('8'),
              SizedBox(width: AppSpacing.md),
              _buildNumberButton('9'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          // Row 4: ., 0, backspace
          Row(
            children: [
              _buildActionButton(
                label: '.',
                onPressed: onDecimalPressed,
              ),
              SizedBox(width: AppSpacing.md),
              _buildNumberButton('0'),
              SizedBox(width: AppSpacing.md),
              _buildActionButton(
                icon: Icons.backspace_outlined,
                onPressed: onBackspacePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: ElevatedButton(
          onPressed: () => onNumberPressed(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    String? label,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.whiteTertiary,
            foregroundColor: AppColors.textSecondary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 24)
              : Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
