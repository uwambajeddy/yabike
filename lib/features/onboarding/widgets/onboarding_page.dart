import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/onboarding_model.dart';

/// Individual onboarding page widget
class OnboardingPage extends StatelessWidget {
  final OnboardingModel onboardingData;

  const OnboardingPage({
    super.key,
    required this.onboardingData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Flexible(
            flex: 3,
            child: Image.asset(
              onboardingData.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 100,
                    color: AppColors.primary300,
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: AppSpacing.sectionSpacing),

          // Title
          Text(
            onboardingData.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.lg),

          // Description
          Text(
            onboardingData.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
