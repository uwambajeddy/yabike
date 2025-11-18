import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings', style: theme.appBarTheme.titleTextStyle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(context),
            const SizedBox(height: 24),
            
            // Settings Menu
            _buildSettingsMenu(context),
            const SizedBox(height: 24),
            
            // App Info Section
            _buildAppInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your account settings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.primary600,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    final theme = Theme.of(context);
    
    final menuItems = [
      _SettingsMenuItem(
        icon: Icons.category,
        title: 'Categories',
        subtitle: 'Manage transaction categories',
        onTap: () => _navigateToCategories(context),
      ),
      _SettingsMenuItem(
        icon: Icons.account_balance_wallet,
        title: 'Wallets',
        subtitle: 'Manage your wallets',
        onTap: () {
          // TODO: Navigate to wallets management
        },
      ),
      _SettingsMenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Configure notification settings',
        onTap: () {
          // TODO: Navigate to notifications settings
        },
      ),
      _SettingsMenuItem(
        icon: Icons.security,
        title: 'Security',
        subtitle: 'Privacy and security settings',
        onTap: () {
          // TODO: Navigate to security settings
        },
      ),
      _SettingsMenuItem(
        icon: Icons.palette,
        title: 'Appearance',
        subtitle: 'Theme and display settings',
        onTap: () {
          // TODO: Navigate to appearance settings
        },
      ),
      _SettingsMenuItem(
        icon: Icons.backup,
        title: 'Data Management',
        subtitle: 'Backup and restore data',
        onTap: () {
          // TODO: Navigate to data management
        },
      ),
      _SettingsMenuItem(
        icon: Icons.help,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: () {
          // TODO: Navigate to help screen
        },
      ),
      _SettingsMenuItem(
        icon: Icons.info,
        title: 'About',
        subtitle: 'App version and information',
        onTap: () {
          // TODO: Navigate to about screen
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...menuItems.map((item) => _buildMenuItem(context, item)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, _SettingsMenuItem item) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayPrimary),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Version', '1.0.0'),
          _buildInfoRow('Build', '2024.01.01'),
          _buildInfoRow('Platform', 'Flutter'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoriesScreen(),
      ),
    );
  }
}

class _SettingsMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

