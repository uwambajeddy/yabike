import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/onboarding_model.dart';
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
              child: SizedBox(
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
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
