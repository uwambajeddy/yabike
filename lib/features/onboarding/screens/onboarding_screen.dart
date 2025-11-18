import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/onboarding_model.dart';
import '../../../data/services/backup_service.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';

/// Onboarding screen with multiple pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding pages content
  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      title: 'Take Control of Your Finances',
      description:
          'Empower yourself financially with Yabike!  Our intuitive app makes it easy to track your income, expenses, and budget - all in one place.',
      imagePath: 'assets/images/onboarding/onboarding1.png',
    ),
    OnboardingModel(
      title: 'Budgeting Made Simple',
      description:
          'We help you categorize your spending, identify areas to save, and stay on top of your financial goals.',
      imagePath: 'assets/images/onboarding/onboarding2.png',
    ),
    OnboardingModel(
      title: 'Smart Insights',
      description:
          'Get detailed insights about your spending patterns and make better financial decisions.  Enjoy automatic transaction tracking and a holistic view of your finances.',
      imagePath: 'assets/images/onboarding/onboarding3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    // Save onboarding completion status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    if (!mounted) return;
    
    // Check platform - Android users go to SMS integration, iOS users to manual wallet creation
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    
    if (isAndroid) {
      // Android: Show SMS Terms & Conditions
      Navigator.of(context).pushReplacementNamed(AppRoutes.smsTerms);
    } else {
      // iOS/Other: Manual wallet creation
      Navigator.of(context).pushReplacementNamed(AppRoutes.createWallet);
    }
  }

  void _restoreFromBackup() async {
    // Mark onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Checking for backup...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      final backupService = BackupService();
      await backupService.initialize();
      
      // Sign in to Google Drive
      final account = await backupService.signIn();
      
      if (account == null) {
        // User cancelled sign in
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog
        return;
      }
      
      // Check if backup exists
      final hasBackup = await backupService.hasBackup();
      
      if (!hasBackup) {
        // No backup found, navigate to normal flow
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No backup found. Setting up new account...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Continue with normal onboarding
        final isAndroid = defaultTargetPlatform == TargetPlatform.android;
        if (isAndroid) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.smsTerms);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.createWallet);
        }
        return;
      }
      
      // Backup exists, restore it
      if (mounted) {
        Navigator.of(context).pop(); // Close checking dialog
        
        // Show restoring dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Restoring your data...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      
      await backupService.restoreData();
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close restoring dialog
      
      // Navigate to home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      
      // Show success message
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Backup restored successfully!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
      
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close any open dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.lg,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    AppStrings.skip,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    onboardingData: _pages[index],
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: PageIndicator(
                pageCount: _pages.length,
                currentPage: _currentPage,
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? AppStrings.getStarted
                            : AppStrings.next,
                      ),
                    ),
                  ),
                  // Show "Restore from Backup" option on the last page
                  if (_currentPage == _pages.length - 1) ...[
                    SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _restoreFromBackup,
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Restore from Backup'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          side: BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
