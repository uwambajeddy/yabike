/// Configuration constants for backup functionality
class BackupConfig {
  static const String tableName = 'user_backups';
  static const String bucketName = 'backup-storage';
  
  // Backup settings
  static const Duration autoBackupInterval = Duration(hours: 24);
  static const int maxBackupsPerUser = 10;
  static const int maxBackupSizeMB = 100; // 100 MB limit per backup
  
  // File names
  static const String settingsFileName = 'settings.json';
  static const String walletsFileName = 'wallets.json';
  static const String transactionsFileName = 'transactions.json';
  static const String budgetsFileName = 'budgets.json';
  
  // Encryption
  static const String encryptionPrefix = 'YABIKE_ENCRYPTED_';
  
  // UI Messages
  static const String backupSuccessMessage = 'Backup completed successfully!';
  static const String backupFailureMessage = 'Backup failed. Please try again.';
  static const String restoreSuccessMessage = 'Data restored successfully!';
  static const String restoreFailureMessage = 'Restore failed. Please try again.';
  
  // Auto backup preferences keys
  static const String autoBackupEnabledKey = 'auto_backup_enabled';
  static const String lastBackupTimeKey = 'last_backup_time';
  
  // Supabase table schema
  static const Map<String, String> tableSchema = {
    'id': 'TEXT PRIMARY KEY',
    'user_id': 'TEXT NOT NULL',
    'backup_name': 'TEXT NOT NULL',
    'created_at': 'TIMESTAMP WITH TIME ZONE DEFAULT NOW()',
    'updated_at': 'TIMESTAMP WITH TIME ZONE DEFAULT NOW()',
    'data_size': 'BIGINT NOT NULL DEFAULT 0',
    'version': 'INTEGER NOT NULL DEFAULT 1',
    'wallets_data': 'JSONB',
    'transactions_data': 'JSONB',
    'budgets_data': 'JSONB',
    'settings_data': 'JSONB',
    'encryption_key': 'TEXT',
    'checksum': 'TEXT',
  };
}

/// Backup error codes and messages
class BackupErrors {
  static const String networkError = 'NETWORK_ERROR';
  static const String storageError = 'STORAGE_ERROR';
  static const String encryptionError = 'ENCRYPTION_ERROR';
  static const String authenticationError = 'AUTH_ERROR';
  static const String sizeLimitError = 'SIZE_LIMIT_ERROR';
  static const String dataCorruptionError = 'DATA_CORRUPTION_ERROR';
  
  static const Map<String, String> errorMessages = {
    networkError: 'Network connection failed. Please check your internet connection.',
    storageError: 'Storage operation failed. Please try again later.',
    encryptionError: 'Data encryption failed. Please contact support.',
    authenticationError: 'Authentication failed. Please sign in again.',
    sizeLimitError: 'Backup size exceeds limit. Please reduce your data size.',
    dataCorruptionError: 'Backup data is corrupted. Please create a new backup.',
  };
}