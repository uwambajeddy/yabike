import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/services/backup_service.dart';
// import '../../../data/models/backup_model.dart'; // No longer needed with simplified backup structure

/// Backup screen with WhatsApp-like interface
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  late BackupService _backupService;
  List<Map<String, dynamic>> _availableBackups = []; // Updated to match new return type

  @override
  void initState() {
    super.initState();
    _backupService = context.read<BackupService>();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final backups = await _backupService.getAvailableBackups();
    if (mounted) {
      setState(() {
        _availableBackups = backups;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chat Backup'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BackupService>(
        builder: (context, backupService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackupSettings(backupService),
                const SizedBox(height: AppSpacing.xxl),
                _buildCurrentBackupInfo(backupService),
                const SizedBox(height: AppSpacing.xxl),
                _buildBackupActions(backupService),
                if (_availableBackups.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  _buildBackupHistory(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackupSettings(BackupService backupService) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Back up your financial data to Supabase cloud storage. You can restore them on a new device after you download YaBike on it.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Account Section with enhanced visual prominence
          Container(
            decoration: BoxDecoration(
              color: backupService.currentUser != null ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(
                color: backupService.currentUser != null ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                onTap: () {
                  if (backupService.currentUser != null) {
                    // User is signed in, show sign out option
                    _showSignOutDialog(context, backupService);
                  } else {
                    // User not signed in, show auth dialog
                    _showEmailAuthDialog(context, backupService);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: backupService.currentUser != null ? AppColors.success : AppColors.warning,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        child: Icon(
                          backupService.currentUser != null ? Icons.verified_user : Icons.person_add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              backupService.currentUser != null ? 'Signed In' : 'Sign In Required',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              backupService.currentUser != null 
                                ? (backupService.currentUser?.email ?? 'Unknown user')
                                : 'Tap here to sign in with your email',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        backupService.currentUser != null ? Icons.logout : Icons.arrow_forward_ios,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          _buildSettingsTile(
            'Auto backup',
            backupService.isAutoBackupEnabled() ? 'Daily' : 'Off',
            Icons.schedule,
            trailing: Switch(
              value: backupService.isAutoBackupEnabled(),
              onChanged: (value) async {
                if (value) {
                  await backupService.enableAutoBackup();
                } else {
                  await backupService.disableAutoBackup();
                }
                setState(() {});
              },
              activeTrackColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBackupInfo(BackupService backupService) {
    final lastBackup = backupService.status.lastBackup;
    final totalBackups = backupService.status.totalBackups;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_done,
                color: lastBackup != null ? AppColors.success : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                lastBackup != null ? 'Last Backup' : 'No Backup',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (lastBackup != null) ...[
            Text(
              _formatBackupDate(lastBackup),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$totalBackups total backups',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            Text(
              'No backups found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          
          // Progress bar for ongoing operations
          if (backupService.status.isBackingUp || backupService.status.isRestoring) ...[
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(
              value: backupService.status.backupProgress,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              backupService.status.isBackingUp ? 'Backing up...' : 'Restoring...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupActions(BackupService backupService) {
    final isLoading = backupService.status.isBackingUp || backupService.status.isRestoring;
    final isSignedIn = backupService.currentUser != null;
    
    return Column(
      children: [
        // Authentication Status Banner (only show when not signed in)
        if (!isSignedIn) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign in required',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'You need to sign in to backup and restore your data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        
        // Manual Backup Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _performBackup,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSignedIn ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (backupService.status.isBackingUp) ...[
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ] else ...[
                  Icon(isSignedIn ? Icons.backup : Icons.login, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  backupService.status.isBackingUp 
                    ? 'Backing up...' 
                    : isSignedIn 
                      ? 'Back up now' 
                      : 'Sign in to backup',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Restore Button
        if (backupService.status.totalBackups > 0) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: isLoading ? null : _showRestoreDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (backupService.status.isRestoring) ...[
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ] else ...[
                    const Icon(Icons.restore, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    backupService.status.isRestoring ? 'Restoring...' : 'Restore from backup',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBackupHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Backup History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableBackups.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.border,
            ),
            itemBuilder: (context, index) {
              final backup = _availableBackups[index];
              return _buildBackupTile(backup);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackupTile(Map<String, dynamic> backup) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        child: Icon(
          Icons.cloud_done,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        backup['backup_name'] as String? ?? 'Unnamed Backup',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        _backupService.getFormattedSize(backup['backup_size_bytes'] as int? ?? 0),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'restore') {
            await _restoreBackup(backup['backup_name'] as String);
          } else if (value == 'delete') {
            await _deleteBackup(backup['backup_name'] as String);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'restore',
            child: Row(
              children: [
                Icon(Icons.restore, size: 20),
                SizedBox(width: 8),
                Text('Restore'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Future<void> _performBackup() async {
    // Check if user is authenticated
    if (_backupService.currentUser == null) {
      await _showEmailAuthDialog(context, _backupService);
      return;
    }

    final success = await _backupService.createBackup();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Backup completed successfully!' : 'Backup failed. Please try again.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) {
        _loadBackups();
      }
    }
  }

  Future<void> _showRestoreDialog() async {
    // Check if user is authenticated
    if (_backupService.currentUser == null) {
      await _showEmailAuthDialog(context, _backupService);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from Backup'),
        content: const Text(
          'This will replace all current data with your latest backup. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _backupService.restoreFromLatestBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Data restored successfully!' : 'Restore failed. Please try again.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(String backupName) async {
    // Check if user is authenticated
    if (_backupService.currentUser == null) {
      await _showEmailAuthDialog(context, _backupService);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all current data with the selected backup. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _backupService.restoreFromBackup(backupName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Data restored successfully!' : 'Restore failed. Please try again.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteBackup(String backupName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Are you sure you want to delete this backup? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _backupService.deleteBackup(backupName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Backup deleted successfully!' : 'Failed to delete backup.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
        if (success) {
          _loadBackups();
        }
      }
    }
  }

  /// Show dialog for email authentication (sign in or sign up)
  Future<void> _showEmailAuthDialog(BuildContext context, BackupService backupService) async {
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
              title: Text(isSignUp ? 'Create Backup Account' : 'Sign In to Backup'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSignUp 
                        ? 'Create an account to securely backup your financial data.' 
                        : 'Sign in to access your secure backup data.',
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account created! Please check your email to verify your account.'),
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
                      setState(() {}); // Refresh the UI
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

  /// Show sign out confirmation dialog
  Future<void> _showSignOutDialog(BuildContext context, BackupService backupService) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out of your backup account?'),
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
                  setState(() {});
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

  String _formatBackupDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}