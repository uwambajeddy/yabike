import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/services/backup_service.dart';
import '../screens/backup_screen.dart';
import '../screens/backup_onboarding_screen.dart';

/// Backup menu tile for settings screen
class BackupMenuTile extends StatelessWidget {
  const BackupMenuTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BackupService>(
      builder: (context, backupService, child) {
        final hasBackups = backupService.status.totalBackups > 0;
        final isConnected = backupService.userEmail != null;
        final lastBackup = backupService.status.lastBackup;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _getStatusColor(isConnected, hasBackups).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Icon(
                _getStatusIcon(isConnected, hasBackups),
                color: _getStatusColor(isConnected, hasBackups),
                size: 24,
              ),
            ),
            title: Text(
              'Chat Backup',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getStatusText(isConnected, hasBackups, lastBackup),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (backupService.status.isBackingUp || backupService.status.isRestoring) ...[
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: backupService.status.backupProgress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    backupService.status.isBackingUp ? 'Backing up...' : 'Restoring...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasBackups) ...[
                  Text(
                    '${backupService.status.totalBackups}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            onTap: () {
              if (hasBackups || isConnected) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BackupScreen(),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BackupOnboardingScreen(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(bool isConnected, bool hasBackups) {
    if (hasBackups) {
      return Icons.cloud_done;
    } else if (isConnected) {
      return Icons.cloud_outlined;
    } else {
      return Icons.cloud_off;
    }
  }

  Color _getStatusColor(bool isConnected, bool hasBackups) {
    if (hasBackups) {
      return AppColors.success;
    } else if (isConnected) {
      return AppColors.warning;
    } else {
      return AppColors.textSecondary;
    }
  }

  String _getStatusText(bool isConnected, bool hasBackups, DateTime? lastBackup) {
    if (!isConnected) {
      return 'Not connected • Tap to set up backup';
    } else if (!hasBackups) {
      return 'No backups • Tap to create first backup';
    } else if (lastBackup != null) {
      final now = DateTime.now();
      final difference = now.difference(lastBackup);
      
      if (difference.inDays > 7) {
        return 'Last backup: ${lastBackup.day}/${lastBackup.month}/${lastBackup.year}';
      } else if (difference.inDays > 0) {
        return 'Last backup: ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return 'Last backup: ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else {
        return 'Last backup: Today';
      }
    } else {
      return 'Backup available • Tap to manage';
    }
  }
}

/// Simple backup button for quick access
class BackupQuickActionButton extends StatelessWidget {
  const BackupQuickActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BackupService>(
      builder: (context, backupService, child) {
        if (backupService.status.isBackingUp) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Backing up...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return IconButton(
          onPressed: () async {
            final success = await backupService.createBackup();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Backup completed!' : 'Backup failed. Try again.',
                  ),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                ),
              );
            }
          },
          icon: Icon(
            Icons.backup,
            color: AppColors.primary,
          ),
          tooltip: 'Create backup',
        );
      },
    );
  }
}