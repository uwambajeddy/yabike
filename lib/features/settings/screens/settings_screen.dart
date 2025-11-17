import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/backup_service.dart';
import '../../backup/widgets/backup_menu_tile.dart';
import 'categories_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationOnEntry();
    });
  }

  /// Check if user is authenticated when accessing settings
  void _checkAuthenticationOnEntry() {
    final backupService = context.read<BackupService>();
    
    // If user is not signed in, show authentication dialog
    if (backupService.currentUser == null) {
      _showAuthenticationRequired();
    }
  }

  /// Show authentication required dialog with options to sign in or continue without account
  Future<void> _showAuthenticationRequired() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Sign In Recommended'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To access all features in Settings, we recommend signing in with your account.',
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                '• Backup your financial data securely',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '• Sync settings across devices',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '• Access cloud features',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // User chooses to continue without signing in
              },
              child: const Text('Continue Without Account'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEmailAuthDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  /// Show email authentication dialog (sign in/sign up)
  Future<void> _showEmailAuthDialog() async {
    final backupService = context.read<BackupService>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isSignUp = false;
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isSignUp ? 'Create Account' : 'Sign In'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSignUp 
                        ? 'Create an account to access all settings features.' 
                        : 'Sign in to access your account settings.',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'example@email.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          isSignUp = !isSignUp;
                        });
                      },
                      child: Text(
                        isSignUp 
                          ? 'Already have an account? Sign In' 
                          : 'Don\'t have an account? Sign Up',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    
                    if (email.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid email address'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    
                    if (password.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password must be at least 6 characters'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      isLoading = true;
                    });

                    bool success;
                    if (isSignUp) {
                      success = await backupService.signUpWithEmail(email, password);
                      if (success) {
                        if (mounted) {
                          Navigator.of(context).pop();
                          setState(() {}); // Refresh the settings screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account created! Please check your email to verify.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                        return;
                      }
                    } else {
                      success = await backupService.signInWithEmail(email, password);
                    }

                    setDialogState(() {
                      isLoading = false;
                    });

                    if (success && mounted) {
                      Navigator.of(context).pop();
                      setState(() {}); // Refresh the settings screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully signed in as: $email'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else if (mounted) {
                      final errorMessage = backupService.status.lastError ?? 'Authentication failed';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isSignUp ? 'Sign Up' : 'Sign In'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings', style: theme.appBarTheme.titleTextStyle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Sign out button when user is authenticated
          Consumer<BackupService>(
            builder: (context, backupService, child) {
              if (backupService.currentUser != null) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: () => _showSignOutDialog(backupService),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<BackupService>(
        builder: (context, backupService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section with authentication status
                _buildProfileSection(context, backupService),
                const SizedBox(height: 24),
                
                // Settings Menu
                _buildSettingsMenu(context),
                const SizedBox(height: 24),
                
                // App Info Section
                _buildAppInfoSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show sign out confirmation dialog
  Future<void> _showSignOutDialog(BackupService backupService) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out? You will need to sign in again to access cloud features.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await backupService.signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh the UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully signed out'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context, BackupService backupService) {
    final theme = Theme.of(context);
    final isSignedIn = backupService.currentUser != null;
    final userEmail = backupService.currentUser?.email ?? 'Not signed in';
    
    return GestureDetector(
      onTap: () {
        if (isSignedIn) {
          _showSignOutDialog(backupService);
        } else {
          _showEmailAuthDialog();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSignedIn ? AppColors.primary100 : AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSignedIn ? AppColors.primary200 : AppColors.warning.withOpacity(0.3)
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSignedIn ? AppColors.primary : AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSignedIn ? Icons.account_circle : Icons.person_add,
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
                    isSignedIn ? 'Signed In' : 'Sign In Required',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSignedIn ? AppColors.primary700 : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSignedIn ? userEmail : 'Tap to sign in and access all features',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSignedIn ? AppColors.primary600 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSignedIn ? Icons.logout : Icons.arrow_forward_ios,
              color: isSignedIn ? AppColors.primary600 : AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
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
        
        // Backup Menu Tile (Special UI)
        const BackupMenuTile(),
        
        // Regular menu items
        ...menuItems.where((item) => item.title != 'Data Management').map((item) => _buildMenuItem(context, item)),
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

