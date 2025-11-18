import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum BackupFrequency {
  off('Off'),
  manual('Only when I tap "Create Backup"'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  final String label;
  const BackupFrequency(this.label);
}

class BackupService {
  // The specific scope for the hidden App Data folder
  final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _currentUser;
  
  // Get the logged-in user
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Initialize and check if user is already signed in
  Future<void> initialize() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('Error during silent sign-in: $e');
    }
  }

  /// Sign in to Google Drive
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return null;
    }
  }

  /// Sign out from Google Drive
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Switch Google accounts (sign out and sign in with different account)
  Future<GoogleSignInAccount?> switchAccount() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      debugPrint('Error switching account: $e');
      return null;
    }
  }

  /// Get current backup frequency setting
  BackupFrequency getBackupFrequency() {
    final settingsBox = Hive.box('settings');
    final frequencyString = settingsBox.get('backup_frequency', defaultValue: 'monthly') as String;
    return BackupFrequency.values.firstWhere(
      (e) => e.name == frequencyString,
      orElse: () => BackupFrequency.monthly,
    );
  }

  /// Set backup frequency
  Future<void> setBackupFrequency(BackupFrequency frequency) async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('backup_frequency', frequency.name);
    debugPrint('Backup frequency set to: ${frequency.label}');
  }

  /// Get last backup timestamp
  DateTime? getLastBackupTime() {
    final settingsBox = Hive.box('settings');
    final timestamp = settingsBox.get('last_backup_time') as int?;
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Update last backup timestamp
  Future<void> _updateLastBackupTime() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('last_backup_time', DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if automatic backup is due based on frequency setting
  bool isBackupDue() {
    final frequency = getBackupFrequency();
    if (frequency == BackupFrequency.off || frequency == BackupFrequency.manual) {
      return false;
    }

    final lastBackup = getLastBackupTime();
    if (lastBackup == null) return true; // Never backed up

    final now = DateTime.now();
    final difference = now.difference(lastBackup);

    switch (frequency) {
      case BackupFrequency.daily:
        return difference.inDays >= 1;
      case BackupFrequency.weekly:
        return difference.inDays >= 7;
      case BackupFrequency.monthly:
        return difference.inDays >= 30;
      default:
        return false;
    }
  }

  /// Open Google Drive storage management page
  Future<void> openManageStorage() async {
    const url = 'https://one.google.com/storage';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error opening storage management: $e');
    }
  }

  /// Get Google Drive storage quota information
  Future<Map<String, dynamic>?> getStorageQuota() async {
    if (_currentUser == null) return null;

    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return null;

      final driveApi = drive.DriveApi(httpClient);
      final about = await driveApi.about.get($fields: 'storageQuota');

      if (about.storageQuota == null) return null;

      final quota = about.storageQuota!;
      final limit = quota.limit != null ? int.parse(quota.limit!) : 0;
      final usage = quota.usage != null ? int.parse(quota.usage!) : 0;

      // Convert bytes to GB
      final limitGB = limit / (1024 * 1024 * 1024);
      final usageGB = usage / (1024 * 1024 * 1024);

      return {
        'limitGB': limitGB,
        'usageGB': usageGB,
        'limitFormatted': _formatStorageSize(limit),
        'usageFormatted': _formatStorageSize(usage),
        'percentUsed': limit > 0 ? (usage / limit * 100).toStringAsFixed(0) : '0',
      };
    } catch (e) {
      debugPrint('Error getting storage quota: $e');
      return null;
    }
  }

  /// Format storage size in human-readable format
  String _formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// CREATE BACKUP (Upload to Google Drive)
  Future<void> backupData() async {
    if (_currentUser == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      // Get the authenticated HTTP client
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        throw Exception('Failed to get authenticated client');
      }

      final driveApi = drive.DriveApi(httpClient);

      // Get Hive directory
      final appDir = await getApplicationDocumentsDirectory();
      
      // Create a timestamped backup file
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final zipPath = path.join(appDir.path, 'yabike_backup_$timestamp.zip');
      
      // Create zip file
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      
      // Add all .hive files (excluding .lock files)
      final files = appDir.listSync();
      int fileCount = 0;
      
      for (var file in files) {
        if (file is File && file.path.endsWith('.hive')) {
          encoder.addFile(file);
          fileCount++;
          debugPrint('Added to backup: ${path.basename(file.path)}');
        }
      }
      
      encoder.close();
      
      if (fileCount == 0) {
        throw Exception('No Hive database files found to backup');
      }

      final zipFile = File(zipPath);
      final fileSizeKB = (zipFile.lengthSync() / 1024).toStringAsFixed(2);
      debugPrint('Backup file created: $fileSizeKB KB, $fileCount databases');

      // Update last backup timestamp
      await _updateLastBackupTime();

      // Check if backup already exists
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder', 
        q: "name = 'yabike_backup.zip'",
      );

      final driveFile = drive.File();
      driveFile.name = 'yabike_backup.zip';
      driveFile.description = 'YaBike backup created on $timestamp';
      
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing file
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(
          driveFile,
          fileId,
          uploadMedia: drive.Media(zipFile.openRead(), zipFile.lengthSync()),
        );
        debugPrint('Backup updated successfully');
      } else {
        // Create new file
        driveFile.parents = ['appDataFolder']; // Hidden folder
        await driveApi.files.create(
          driveFile,
          uploadMedia: drive.Media(zipFile.openRead(), zipFile.lengthSync()),
        );
        debugPrint('Backup created successfully');
      }
      
      // Cleanup local zip
      if (zipFile.existsSync()) {
        zipFile.deleteSync();
      }
    } catch (e) {
      debugPrint('Error during backup: $e');
      rethrow;
    }
  }

  /// RESTORE DATA (Download from Google Drive)
  Future<void> restoreData() async {
    if (_currentUser == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        throw Exception('Failed to get authenticated client');
      }
      
      final driveApi = drive.DriveApi(httpClient);

      // Find the backup file
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'yabike_backup.zip'",
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        throw Exception('No backup found on Google Drive');
      }

      final fileId = fileList.files!.first.id!;
      debugPrint('Found backup file with ID: $fileId');

      // Download the file
      final drive.Media media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final appDir = await getApplicationDocumentsDirectory();
      final zipPath = path.join(appDir.path, 'restored_yabike.zip');
      final saveFile = File(zipPath);
      
      // Download to file
      final List<int> dataStore = [];
      await for (var data in media.stream) {
        dataStore.addAll(data);
      }
      
      await saveFile.writeAsBytes(dataStore);
      debugPrint('Backup downloaded: ${(saveFile.lengthSync() / 1024).toStringAsFixed(2)} KB');

      // CRITICAL: Close all Hive boxes before overwriting
      await Hive.close();
      debugPrint('Closed all Hive boxes');

      // Unzip and overwrite
      final bytes = saveFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      int restoredCount = 0;
      for (var file in archive) {
        if (file.isFile && file.name.endsWith('.hive')) {
          final outputPath = path.join(appDir.path, file.name);
          final outputFile = File(outputPath);
          outputFile.writeAsBytesSync(file.content as List<int>);
          restoredCount++;
          debugPrint('Restored: ${file.name}');
        }
      }
      
      // Cleanup
      if (saveFile.existsSync()) {
        saveFile.deleteSync();
      }
      
      debugPrint('Restore complete: $restoredCount databases restored');
      
      // Reopen Hive boxes to refresh the app
      await reopenHiveBoxes();
      debugPrint('Reopened all Hive boxes - app refreshed');
    } catch (e) {
      debugPrint('Error during restore: $e');
      rethrow;
    }
  }
  
  /// Check if a backup exists on Google Drive
  Future<bool> hasBackup() async {
    if (_currentUser == null) return false;
    
    try {
      final info = await getBackupInfo();
      return info != null && info['exists'] == true;
    } catch (e) {
      debugPrint('Error checking for backup: $e');
      return false;
    }
  }

  /// Reopen all Hive boxes after restore
  Future<void> reopenHiveBoxes() async {
    try {
      debugPrint('Opening wallets box...');
      await Hive.openBox('wallets');
      debugPrint('Opening transactions box...');
      await Hive.openBox('transactions');
      debugPrint('Opening budgets box...');
      await Hive.openBox('budgets');
      debugPrint('Opening settings box...');
      await Hive.openBox('settings');
      
      // Verify boxes were opened successfully
      debugPrint('✅ Wallets: ${Hive.box('wallets').length} items');
      debugPrint('✅ Transactions: ${Hive.box('transactions').length} items');
      debugPrint('✅ Budgets: ${Hive.box('budgets').length} items');
      debugPrint('✅ Settings: ${Hive.box('settings').length} items');
    } catch (e) {
      debugPrint('Error reopening Hive boxes: $e');
      rethrow;
    }
  }

  /// Get backup info from Google Drive
  Future<Map<String, dynamic>?> getBackupInfo() async {
    if (_currentUser == null) return null;

    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return null;
      
      final driveApi = drive.DriveApi(httpClient);

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'yabike_backup.zip'",
        $fields: 'files(id, name, size, modifiedTime, description)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return null;
      }

      final file = fileList.files!.first;
      return {
        'exists': true,
        'size': file.size != null ? (int.parse(file.size!) / 1024).toStringAsFixed(2) : 'Unknown',
        'lastModified': file.modifiedTime,
        'description': file.description,
      };
    } catch (e) {
      debugPrint('Error getting backup info: $e');
      return null;
    }
  }

  /// Delete backup from Google Drive
  Future<void> deleteBackup() async {
    if (_currentUser == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        throw Exception('Failed to get authenticated client');
      }
      
      final driveApi = drive.DriveApi(httpClient);

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'yabike_backup.zip'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final fileId = fileList.files!.first.id!;
        await driveApi.files.delete(fileId);
        debugPrint('Backup deleted successfully');
      }
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      rethrow;
    }
  }
}
