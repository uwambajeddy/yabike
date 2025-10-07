import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_spacing.dart';

/// Splash screen displayed on app launch
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: Navigate to onboarding or home based on first launch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.whitePrimary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackQuinary.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAssets.logo,
                  width: 80,
                  height: 80,
                ),
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              // App name
              Text(
                'YaBike',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // Tagline
              Text(
                'Smart Finance Management',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.whitePrimary.withOpacity(0.9),
                    ),
              ),
              
              SizedBox(height: AppSpacing.xxxl),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.whitePrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
