import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_icons.dart';

/// Main home screen/dashboard
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // App logo
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 12),
            const Text(AppStrings.homeTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            iconSize: AppIcons.iconSizeLarge,
            onPressed: () {
              // TODO: Open notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Card
            _buildBalanceCard(context),
            SizedBox(height: AppSpacing.sectionSpacing),

            // Quick Actions
            _buildQuickActions(context),
            SizedBox(height: AppSpacing.sectionSpacing),

            // Recent Transactions
            _buildSectionHeader(
              context,
              AppStrings.recentTransactions,
              onSeeAll: () {
                // TODO: Navigate to transactions
              },
            ),
            SizedBox(height: AppSpacing.md),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.totalBalance,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textWhite.withOpacity(0.9),
                ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '0 RWF', // TODO: Calculate total balance
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionButton(
          context,
          icon: Icons.add_circle_outline,
          label: 'Add\nTransaction',
          onTap: () {
            // TODO: Navigate to add transaction
          },
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Create\nWallet',
          onTap: () {
            // TODO: Navigate to create wallet
          },
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.trending_up,
          label: 'Create\nBudget',
          onTap: () {
            // TODO: Navigate to create budget
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackQuinary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: AppIcons.iconSizeXLarge,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(AppStrings.seeAll),
          ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    // TODO: Fetch and display recent transactions
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: AppIcons.iconSizeXXLarge,
              color: AppColors.grayTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.emptyTransactions,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
