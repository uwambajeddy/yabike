import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  Map<String, dynamic>? _backupInfo;
  Map<String, dynamic>? _storageQuota;
  BackupFrequency _selectedFrequency = BackupFrequency.monthly;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    try {
      await _backupService.initialize();
      _selectedFrequency = _backupService.getBackupFrequency();
      if (_backupService.isSignedIn) {
        await _loadBackupInfo();
      }
    } catch (e) {
      debugPrint('Error initializing backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBackupInfo() async {
    try {
      final info = await _backupService.getBackupInfo();
      final quota = await _backupService.getStorageQuota();
      setState(() {
        _backupInfo = info;
        _storageQuota = quota;
      });
    } catch (e) {
      debugPrint('Error loading backup info: $e');
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final account = await _backupService.signIn();
      if (account != null) {
        _showSnackBar('Signed in as ${account.email}', isError: false);
        await _loadBackupInfo();
      } else {
        _showSnackBar('Sign-in cancelled');
      }
    } catch (e) {
      _showSnackBar('Failed to sign in: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _switchAccount() async {
    setState(() => _isLoading = true);
    try {
      final account = await _backupService.switchAccount();
      if (account != null) {
        _showSnackBar('Switched to ${account.email}', isError: false);
        await _loadBackupInfo();
      } else {
        _showSnackBar('Account switch cancelled');
      }
    } catch (e) {
      _showSnackBar('Failed to switch account: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    try {
      await _backupService.backupData();
      await _loadBackupInfo();
      _showSnackBar('Backup created successfully!', isError: false);
    } catch (e) {
      _showSnackBar('Backup failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirm = await _showConfirmDialog(
      title: 'Restore Backup',
      message: 'This will overwrite all your current data and refresh the app. Continue?',
      isDangerous: true,
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _backupService.restoreData();
      if (mounted) {
        _showSnackBar('Restore successful! Data refreshed.', isError: false);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Restore failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBackup() async {
    final confirm = await _showConfirmDialog(
      title: 'Delete Backup',
      message: 'This will permanently delete your backup from Google Drive. This action cannot be undone. Continue?',
      isDangerous: true,
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _backupService.deleteBackup();
      if (mounted) {
        setState(() => _backupInfo = null);
        _showSnackBar('Backup deleted successfully', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to delete backup: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onFrequencyChanged(BackupFrequency? frequency) async {
    if (frequency == null) return;
    
    setState(() => _selectedFrequency = frequency);
    await _backupService.setBackupFrequency(frequency);
    
    if (frequency == BackupFrequency.off) {
      _showSnackBar('Automatic backups turned off', isError: false);
    } else {
      _showSnackBar('Backup frequency set to ${frequency.label}', isError: false);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDangerous ? Colors.red : AppColors.primary,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSignedIn = _backupService.isSignedIn;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSignedIn) ...[
                    _buildSignInCard(theme),
                  ] else ...[
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your data is backed up to Google Drive and can be restored on any device.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Account info at the top
                    _buildGoogleAccountCard(),
                    const SizedBox(height: 24),

                    // Last Backup Info
                    if (_backupInfo != null) ...[
                      _buildBackupInfoSection(theme),
                      const SizedBox(height: 16),
                    ],

                    // Back up button
                    _buildBackupButton(),
                    const SizedBox(height: 24),

                    // Google Storage section
                    Text(
                      'Storage',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildManageStorageLink(theme),
                    const SizedBox(height: 24),

                    // Settings section
                    Text(
                      'Settings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAutomaticBackupsTile(),
                    const SizedBox(height: 32),

                    // Restore button (if backup exists)
                    if (_backupInfo != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _restoreBackup,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.primary, width: 1.5),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Restore Backup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _deleteBackup,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.red, width: 1.5),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Delete Backup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSignInCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Backup to Google Drive',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Securely backup your data to Google Drive and restore it anytime',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Connect Google Drive'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupInfoSection(ThemeData theme) {
    final lastBackup = _backupService.getLastBackupTime();
    final size = _backupInfo!['size'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cloud_done,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Last backup',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lastBackup != null) ...[
            _buildInfoRow(
              'Date',
              DateFormat('MMM dd, yyyy').format(lastBackup.toLocal()),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Time',
              DateFormat('h:mm a').format(lastBackup.toLocal()),
            ),
          ],
          if (size != null && size != '0') ...[
            const SizedBox(height: 8),
            _buildInfoRow('Size', '$size KB'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createBackup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Back up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildManageStorageLink(ThemeData theme) {
    if (_storageQuota == null) {
      return const SizedBox.shrink();
    }

    final used = _storageQuota!['usageFormatted'] as String;
    final total = _storageQuota!['limitFormatted'] as String;
    final percentUsed = double.tryParse(_storageQuota!['percentUsed'] as String) ?? 0;
    
    return InkWell(
      onTap: () => _backupService.openManageStorage(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Google storage',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
              ],
            ),
            const SizedBox(height: 12),
            // Storage bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentUsed / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentUsed > 90 ? Colors.red : 
                  percentUsed > 75 ? Colors.orange : 
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$used of $total used',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${percentUsed.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleAccountCard() {
    final email = _backupService.currentUser?.email ?? '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 24,
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connected',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _switchAccount,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              'Switch',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleAccountTile() {
    final email = _backupService.currentUser?.email ?? '';
    
    return InkWell(
      onTap: _switchAccount,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 20,
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomaticBackupsTile() {
    return InkWell(
      onTap: _showAutomaticBackupsModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedFrequency.label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  void _showAutomaticBackupsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Automatic backups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...BackupFrequency.values.map((frequency) {
              return RadioListTile<BackupFrequency>(
                title: Text(frequency.label),
                value: frequency,
                groupValue: _selectedFrequency,
                onChanged: (value) {
                  _onFrequencyChanged(value);
                  Navigator.pop(context);
                },
                activeColor: AppColors.primary,
              );
            }),
          ],
        ),
      ),
    );
  }
}
