import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/backup_model.dart';
// Note: Supabase config is handled in main.dart initialization

/// Comprehensive backup service for YaBike app data
/// Provides WhatsApp-like backup functionality to Supabase
/// Uses AUTHENTICATED EMAIL for secure backup identification
class BackupService extends ChangeNotifier {
  static const String _backupTableName = 'user_backups';
  static const String _userBackupsBox = 'user_backups';
  static const int _currentBackupVersion = 1;
  
  late final SupabaseClient _supabase;
  late Box _backupBox;
  
  BackupStatus _status = const BackupStatus();
  User? _currentUser; // Supabase authenticated user
  
  // Getters
  BackupStatus get status => _status;
  bool get isInitialized => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  User? get currentUser => _currentUser;
  
  BackupService() {
    _initializeSupabase();
  }

  /// Initialize Supabase client and set up auth listener
  Future<void> _initializeSupabase() async {
    try {
      // Supabase is already initialized in main.dart, so just get the instance
      _supabase = Supabase.instance.client;
      
      // Set up auth state listener
      _supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        if (event == AuthChangeEvent.signedIn && session?.user != null) {
          _currentUser = session!.user;
          _loadBackupStatus();
          debugPrint('✅ User signed in: ${_currentUser!.email}');
        } else if (event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          _status = const BackupStatus();
          debugPrint('👋 User signed out');
        }
        notifyListeners();
      });
      
      // Check if user is already signed in
      final session = _supabase.auth.currentSession;
      if (session?.user != null) {
        _currentUser = session!.user;
        await _loadBackupStatus();
      }
      
      // Open backup box
      _backupBox = await Hive.openBox(_userBackupsBox);
      
      debugPrint('✅ BackupService initialized with auth');
    } catch (e) {
      debugPrint('❌ Failed to initialize BackupService: $e');
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _status = _status.copyWith(isBackingUp: true);
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadBackupStatus();
        _status = _status.copyWith(isBackingUp: false);
        notifyListeners();
        debugPrint('✅ Successfully signed in: ${_currentUser!.email}');
        return true;
      }
      
      _status = _status.copyWith(
        isBackingUp: false, 
        lastError: 'Failed to sign in'
      );
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      _status = _status.copyWith(
        isBackingUp: false,
        lastError: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _status = _status.copyWith(isBackingUp: true);
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Note: User needs to verify email before being fully authenticated
        _status = _status.copyWith(isBackingUp: false);
        notifyListeners();
        debugPrint('✅ Successfully signed up: $email (verify email to complete)');
        return true;
      }
      
      _status = _status.copyWith(
        isBackingUp: false,
        lastError: 'Failed to sign up'
      );
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      _status = _status.copyWith(
        isBackingUp: false,
        lastError: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _status = const BackupStatus();
      notifyListeners();
      debugPrint('👋 User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  /// Load backup status from local storage and cloud
  Future<void> _loadBackupStatus() async {
    if (_currentUser == null) return;
    
    try {
      // Get latest backup info from Supabase using email
      final response = await _supabase
          .from(_backupTableName)
          .select('*')
          .eq('user_email', _currentUser!.email!) // Using authenticated user email
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final lastBackup = DateTime.parse(response['created_at']);
        final totalBackups = await _getTotalBackupsCount();
        
        _status = _status.copyWith(
          lastBackup: lastBackup,
          totalBackups: totalBackups,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading backup status: $e');
    }
  }

  /// Get total number of backups for current user email
  Future<int> _getTotalBackupsCount() async {
    if (_currentUser?.email == null) return 0;
    
    try {
      final response = await _supabase
          .from(_backupTableName)
          .select('id')
          .eq('user_email', _currentUser!.email!) // Using authenticated user email
          .count();
      
      return response.count;
    } catch (e) {
      debugPrint('❌ Error getting backup count: $e');
      return 0;
    }
  }

  /// Create a full backup of all user data (requires authentication)
  Future<bool> createBackup({bool isAutomatic = false, String? customBackupName}) async {
    if (_currentUser?.email == null) {
      debugPrint('❌ Cannot create backup: User not authenticated');
      return false;
    }

    _status = _status.copyWith(
      isBackingUp: true,
      backupProgress: 0.0,
      lastError: null,
    );
    notifyListeners();

    try {
      // Step 1: Collect all data from Hive boxes
      _updateProgress(0.1, 'Collecting wallet data...');
      final walletsBox = Hive.box('wallets');
      final walletsData = Map<String, dynamic>.from(walletsBox.toMap());

      _updateProgress(0.3, 'Collecting transaction data...');
      final transactionsBox = Hive.box('transactions');
      final transactionsData = Map<String, dynamic>.from(transactionsBox.toMap());

      _updateProgress(0.5, 'Collecting budget data...');
      final budgetsBox = Hive.box('budgets');
      final budgetsData = Map<String, dynamic>.from(budgetsBox.toMap());

      _updateProgress(0.7, 'Collecting settings...');
      final settingsBox = Hive.box('settings');
      final settingsData = Map<String, dynamic>.from(settingsBox.toMap());

      // Step 2: Create backup data object
      _updateProgress(0.8, 'Preparing backup...');
      
      // Generate backup name (with custom option)
      final backupName = customBackupName ?? 
          (isAutomatic ? 'Auto Backup ${DateTime.now().millisecondsSinceEpoch}' : 
           'Manual Backup ${DateTime.now().toIso8601String().substring(0, 19)}');
      
      final backupData = BackupData(
        id: const Uuid().v4(),
        userId: _currentUser!.email!, // Using authenticated email as identifier
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        version: _currentBackupVersion,
        wallets: walletsData,
        transactions: transactionsData,
        budgets: budgetsData,
        settings: settingsData,
        totalSize: _calculateDataSize(walletsData, transactionsData, budgetsData, settingsData),
      );

      // Step 3: Save to Supabase with email-based data structure
      _updateProgress(0.9, 'Uploading to cloud...');
      final backupRecord = {
        'id': backupData.id,
        'user_email': _currentUser!.email!, // Using authenticated email
        'backup_name': backupName, // Using the backup name
        'backup_data': backupData.toJson(),
        'device_info': {'platform': 'Flutter', 'app': 'YaBike'},
        'app_version': '1.0.0',
        'backup_size_bytes': backupData.totalSize,
        'encrypted': false,
      };
      
      await _supabase.from(_backupTableName).insert(backupRecord);

      // Step 4: Save backup metadata locally using email
      _updateProgress(0.95, 'Saving backup info...');
      await _backupBox.put('last_backup_${_currentUser!.email}', {
        'timestamp': backupData.createdAt.millisecondsSinceEpoch,
        'backup_id': backupData.id,
        'backup_name': backupName,
        'size': backupData.totalSize,
      });

      _updateProgress(1.0, 'Backup completed!');
      
      // Update status
      _status = _status.copyWith(
        isBackingUp: false,
        lastBackup: backupData.createdAt,
        totalBackups: _status.totalBackups + 1,
        backupProgress: 0.0,
      );
      
      debugPrint('✅ Backup created successfully: ${backupData.id}');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Backup failed: $e');
      _status = _status.copyWith(
        isBackingUp: false,
        lastError: 'Backup failed: ${e.toString()}',
        backupProgress: 0.0,
      );
      notifyListeners();
      return false;
    }
  }

  /// Restore data from the latest backup for current authenticated user
  Future<bool> restoreFromLatestBackup() async {
    if (_currentUser?.email == null) {
      debugPrint('❌ Cannot restore: User not authenticated');
      return false;
    }

    return await restoreFromBackup(null); // null means latest backup
  }

  /// Restore data from a specific backup by backup name
  Future<bool> restoreFromBackup(String? backupName) async {
    if (_currentUser?.email == null) {
      debugPrint('❌ Cannot restore: User not authenticated');
      return false;
    }

    _status = _status.copyWith(
      isRestoring: true,
      backupProgress: 0.0,
      lastError: null,
    );
    notifyListeners();

    try {
      // Step 1: Get backup data from Supabase using authenticated user email
      _updateProgress(0.1, 'Fetching backup...');
      
      final query = _supabase
          .from(_backupTableName)
          .select('*')
          .eq('user_email', _currentUser!.email!); // Using authenticated email
      
      final response = backupName != null 
          ? await query.eq('backup_name', backupName).single()
          : await query.order('created_at', ascending: false).limit(1).single();

      // Extract backup data from the new structure
      final backupDataJson = response['backup_data'] as Map<String, dynamic>;
      final backupData = BackupData.fromJson(backupDataJson);
      
      // Step 2: Clear existing data
      _updateProgress(0.3, 'Clearing existing data...');
      await Hive.box('wallets').clear();
      await Hive.box('transactions').clear();
      await Hive.box('budgets').clear();
      await Hive.box('settings').clear();

      // Step 3: Restore data
      _updateProgress(0.5, 'Restoring wallets...');
      final walletsBox = Hive.box('wallets');
      for (final entry in backupData.wallets.entries) {
        await walletsBox.put(entry.key, entry.value);
      }

      _updateProgress(0.7, 'Restoring transactions...');
      final transactionsBox = Hive.box('transactions');
      for (final entry in backupData.transactions.entries) {
        await transactionsBox.put(entry.key, entry.value);
      }

      _updateProgress(0.8, 'Restoring budgets...');
      final budgetsBox = Hive.box('budgets');
      for (final entry in backupData.budgets.entries) {
        await budgetsBox.put(entry.key, entry.value);
      }

      _updateProgress(0.9, 'Restoring settings...');
      final settingsBox = Hive.box('settings');
      for (final entry in backupData.settings.entries) {
        await settingsBox.put(entry.key, entry.value);
      }

      _updateProgress(1.0, 'Restore completed!');

      _status = _status.copyWith(
        isRestoring: false,
        backupProgress: 0.0,
      );

      debugPrint('✅ Data restored successfully from backup: ${backupData.id}');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Restore failed: $e');
      _status = _status.copyWith(
        isRestoring: false,
        lastError: 'Restore failed: ${e.toString()}',
        backupProgress: 0.0,
      );
      notifyListeners();
      return false;
    }
  }

  /// Get list of all available backups for current authenticated user
  Future<List<Map<String, dynamic>>> getAvailableBackups() async {
    if (_currentUser?.email == null) return [];

    try {
      final response = await _supabase
          .from(_backupTableName)
          .select('*')
          .eq('user_email', _currentUser!.email!) // Using authenticated email
          .order('created_at', ascending: false);

      // Return simplified backup info instead of full BackupData objects
      return response.map<Map<String, dynamic>>((json) => {
        'backup_name': json['backup_name'],
        'created_at': json['created_at'],
        'backup_size_bytes': json['backup_size_bytes'],
        'app_version': json['app_version'],
        'encrypted': json['encrypted'],
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching backups: $e');
      return [];
    }
  }

  /// Delete a specific backup by backup name (authenticated user only)
  Future<bool> deleteBackup(String backupName) async {
    if (_currentUser?.email == null) return false;

    try {
      await _supabase
          .from(_backupTableName)
          .delete()
          .eq('backup_name', backupName) // Changed to backup_name
          .eq('user_email', _currentUser!.email!); // Using authenticated email

      await _loadBackupStatus(); // Refresh status
      debugPrint('✅ Backup deleted successfully: $backupName');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting backup: $e');
      return false;
    }
  }

  /// Calculate total size of backup data
  int _calculateDataSize(Map<String, dynamic> wallets, Map<String, dynamic> transactions, 
                         Map<String, dynamic> budgets, Map<String, dynamic> settings) {
    final data = {
      'wallets': wallets,
      'transactions': transactions,
      'budgets': budgets,
      'settings': settings,
    };
    
    return utf8.encode(json.encode(data)).length;
  }

  /// Update backup progress
  void _updateProgress(double progress, String message) {
    _status = _status.copyWith(backupProgress: progress);
    debugPrint('🔄 Backup progress: ${(progress * 100).toInt()}% - $message');
    notifyListeners();
  }

  /// Enable automatic daily backups
  Future<void> enableAutoBackup() async {
    if (_currentUser?.email == null) return;
    
    final settingsBox = Hive.box('settings');
    await settingsBox.put('auto_backup_enabled', true);
    await settingsBox.put('auto_backup_frequency', 'daily');
    
    debugPrint('✅ Auto backup enabled');
  }

  /// Disable automatic backups
  Future<void> disableAutoBackup() async {
    if (_currentUser?.email == null) return;
    
    final settingsBox = Hive.box('settings');
    await settingsBox.put('auto_backup_enabled', false);
    
    debugPrint('✅ Auto backup disabled');
  }

  /// Check if auto backup is enabled
  bool isAutoBackupEnabled() {
    final settingsBox = Hive.box('settings');
    return settingsBox.get('auto_backup_enabled', defaultValue: false) as bool;
  }

  /// Get formatted backup size
  String getFormattedSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}