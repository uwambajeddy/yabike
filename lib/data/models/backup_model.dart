import 'package:hive/hive.dart';

/// Model for storing user backup information
/// Uses EMAIL-BASED identification instead of user IDs
@HiveType(typeId: 10)
class BackupData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId; // Keep for backwards compatibility but will store email

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime lastModified;

  @HiveField(4)
  final int version;

  @HiveField(5)
  final Map<String, dynamic> wallets;

  @HiveField(6)
  final Map<String, dynamic> transactions;

  @HiveField(7)
  final Map<String, dynamic> budgets;

  @HiveField(8)
  final Map<String, dynamic> settings;

  @HiveField(9)
  final int totalSize;

  @HiveField(10)
  final bool isEncrypted;

  BackupData({
    required this.id,
    required this.userId, // This will actually contain the email address
    required this.createdAt,
    required this.lastModified,
    required this.version,
    required this.wallets,
    required this.transactions,
    required this.budgets,
    required this.settings,
    required this.totalSize,
    this.isEncrypted = false,
  });

  /// Helper getter to make it clear that userId contains the email
  String get userEmail => userId;

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['user_email'] as String, // Support both for compatibility
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModified: DateTime.parse(json['last_modified'] as String? ?? json['created_at'] as String),
      version: json['version'] as int? ?? 1,
      wallets: json['wallets'] as Map<String, dynamic>? ?? {},
      transactions: json['transactions'] as Map<String, dynamic>? ?? {},
      budgets: json['budgets'] as Map<String, dynamic>? ?? {},
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      totalSize: json['total_size'] as int? ?? json['backup_size_bytes'] as int? ?? 0,
      isEncrypted: json['is_encrypted'] as bool? ?? json['encrypted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // This now contains the email
      'user_email': userId, // Add explicit email field for clarity
      'created_at': createdAt.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
      'version': version,
      'wallets': wallets,
      'transactions': transactions,
      'budgets': budgets,
      'settings': settings,
      'total_size': totalSize,
      'backup_size_bytes': totalSize, // Add for compatibility
      'is_encrypted': isEncrypted,
      'encrypted': isEncrypted, // Add for compatibility
    };
  }

  BackupData copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? lastModified,
    int? version,
    Map<String, dynamic>? wallets,
    Map<String, dynamic>? transactions,
    Map<String, dynamic>? budgets,
    Map<String, dynamic>? settings,
    int? totalSize,
    bool? isEncrypted,
  }) {
    return BackupData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      version: version ?? this.version,
      wallets: wallets ?? this.wallets,
      transactions: transactions ?? this.transactions,
      budgets: budgets ?? this.budgets,
      settings: settings ?? this.settings,
      totalSize: totalSize ?? this.totalSize,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}

/// Backup status information
class BackupStatus {
  final bool isBackingUp;
  final bool isRestoring;
  final DateTime? lastBackup;
  final int totalBackups;
  final double backupProgress;
  final String? lastError;

  const BackupStatus({
    this.isBackingUp = false,
    this.isRestoring = false,
    this.lastBackup,
    this.totalBackups = 0,
    this.backupProgress = 0.0,
    this.lastError,
  });

  BackupStatus copyWith({
    bool? isBackingUp,
    bool? isRestoring,
    DateTime? lastBackup,
    int? totalBackups,
    double? backupProgress,
    String? lastError,
  }) {
    return BackupStatus(
      isBackingUp: isBackingUp ?? this.isBackingUp,
      isRestoring: isRestoring ?? this.isRestoring,
      lastBackup: lastBackup ?? this.lastBackup,
      totalBackups: totalBackups ?? this.totalBackups,
      backupProgress: backupProgress ?? this.backupProgress,
      lastError: lastError ?? this.lastError,
    );
  }
}