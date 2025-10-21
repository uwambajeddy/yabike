import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/screens/home_screen.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../transaction/screens/transactions_screen.dart';
import '../../transaction/viewmodels/transactions_viewmodel.dart';
import '../../budget/screens/budget_screen.dart';
import '../../budget/viewmodels/budget_viewmodel.dart';

/// Main screen with persistent bottom navigation
class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavItemTapped(int index) {
    if (index == 2) {
      // Add button - navigate to add transaction
      Navigator.pushNamed(context, AppRoutes.addTransaction).then((_) {
        // Refresh the current page after adding transaction
        if (_currentIndex == 0) {
          context.read<HomeViewModel>().refresh();
        } else if (_currentIndex == 1) {
          context.read<TransactionsViewModel>().refresh();
        }
      });
    } else {
      // Adjust index for PageView (skip index 2 which is the add button)
      final pageIndex = index > 2 ? index - 1 : index;
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          // Home Tab
          ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomeScreen(showBottomNav: false),
          ),
          
          // Transactions Tab
          ChangeNotifierProvider(
            create: (_) => TransactionsViewModel(),
            child: const TransactionsScreen(showBottomNav: false),
          ),
          
          // Budget Tab
          ChangeNotifierProvider(
            create: (_) => BudgetViewModel(),
            child: const BudgetScreen(),
          ),
          
          // Settings Tab (placeholder)
          const Center(child: Text('Settings - Coming Soon')),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.receipt_long, 'Transactions', 1),
              _buildAddButton(),
              _buildNavItem(Icons.pie_chart, 'Budget', 3),
              _buildNavItem(Icons.settings, 'Settings', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Adjust index for PageView (skip index 2 which is the add button)
    final pageIndex = index > 2 ? index - 1 : index;
    final isActive = _currentIndex == pageIndex;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onNavItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : Colors.grey,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _onNavItemTapped(2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
