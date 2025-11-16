import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:sms_advanced/sms_advanced.dart'; // Temporarily disabled due to compatibility
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
// import '../../../data/services/sms_parser_service.dart'; // Disabled with SMS
// import '../../../data/repositories/wallet_repository.dart'; // Disabled with SMS
// import '../../../data/repositories/transaction_repository.dart'; // Disabled with SMS
import '../../../core/routes/app_routes.dart';

enum SmsIntegrationState {
  initial,
  requestingPermission,
  permissionGranted,
  permissionDenied,
  scanning,
  parsing,
  creatingWallets,
  completed,
  error,
}

class SmsIntegrationViewModel extends ChangeNotifier {
  SmsIntegrationState _state = SmsIntegrationState.initial;
  String? _errorMessage;
  int _totalMessages = 0;
  int _processedMessages = 0;
  List<Wallet> _createdWallets = [];
  List<Transaction> _importedTransactions = [];
  bool _isDisposed = false; // Track disposal state

  // Repository instances - temporarily disabled
  // final WalletRepository _walletRepository = WalletRepository();
  // final TransactionRepository _transactionRepository = TransactionRepository();

  // Getters
  SmsIntegrationState get state => _state;
  String? get errorMessage => _errorMessage;
  int get totalMessages => _totalMessages;
  int get processedMessages => _processedMessages;
  double get progress =>
      _totalMessages > 0 ? _processedMessages / _totalMessages : 0.0;
  List<Wallet> get createdWallets => _createdWallets;
  List<Transaction> get importedTransactions => _importedTransactions;

  /// Request SMS permission from the user
  Future<void> requestSmsPermission(BuildContext context) async {
    try {
      _setState(SmsIntegrationState.requestingPermission);

      final status = await Permission.sms.request();

      if (status.isGranted) {
        _setState(SmsIntegrationState.permissionGranted);
        // Start scanning immediately (no navigation needed)
        await scanAndImportSms();
      } else if (status.isDenied) {
        _setState(SmsIntegrationState.permissionDenied);
        _errorMessage =
            'SMS permission is required to auto-import transactions';
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
      } else if (status.isPermanentlyDenied) {
        _setState(SmsIntegrationState.permissionDenied);
        _errorMessage = 'Please enable SMS permission in settings';
        if (context.mounted) {
          _showOpenSettingsDialog(context);
        }
      }
    } catch (e) {
      _setState(SmsIntegrationState.error);
      _errorMessage = 'Failed to request SMS permission: $e';
    }
  }

  /// Scan SMS messages and import transactions
  /// NOTE: SMS functionality is temporarily disabled due to package compatibility issues
  Future<void> scanAndImportSms() async {
    try {
      _setState(SmsIntegrationState.scanning);
      
      debugPrint('⚠️ SMS functionality is temporarily disabled due to package compatibility issues');
      debugPrint('Please manually add transactions or wait for package update');
      
      // Simulate completion for UI consistency
      await Future.delayed(const Duration(milliseconds: 500));
      _setState(SmsIntegrationState.completed);
    } catch (e) {
      // Only set error state if we haven't already completed
      if (_state != SmsIntegrationState.completed && !_isDisposed) {
        debugPrint('❌ SMS functionality is temporarily disabled');
        debugPrint('Error: $e');
        _setState(SmsIntegrationState.completed); // Complete anyway since SMS is disabled
        _errorMessage = 'SMS functionality is temporarily disabled';
      } else {
        debugPrint('⚠️ Error occurred after completion/disposal - ignoring: $e');
      }
    }
  }

  /* DISABLED SMS METHODS - REMOVE OR COMMENT OUT WHEN SMS PACKAGE IS RE-ENABLED

  /// Parse SMS messages into transactions
  Future<void> _parseSmsMessages(List<dynamic> messages) async {
    debugPrint('⚠️ SMS parsing is temporarily disabled due to package compatibility');
    return;
  }

  /// Create wallets from imported transactions
  Future<void> _createWalletsFromTransactions() async {
    debugPrint('⚠️ Wallet creation from SMS is temporarily disabled');
    return;
  }

  END OF DISABLED SMS METHODS */

  /// Show permission denied dialog
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'SMS permission is required to automatically import your transactions. '
          'You can skip this step and add transactions manually instead.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.createWallet);
            },
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              requestSmsPermission(context);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Show open settings dialog for permanently denied permission
  void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'SMS permission has been permanently denied. '
          'Please enable it in your device settings to use auto-import.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.createWallet);
            },
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _setState(SmsIntegrationState newState) {
    if (_isDisposed) {
      debugPrint('⚠️ Attempted to setState after disposal - state: $newState');
      // Still update the internal state even if disposed, but don't notify
      _state = newState;
      return;
    }
    debugPrint('SMS Integration ViewModel - State changing: $_state -> $newState');
    _state = newState;
    notifyListeners();
    debugPrint('SMS Integration ViewModel - notifyListeners() called for state: $newState');
  }

  @override
  void dispose() {
    _isDisposed = true;
    debugPrint('SMS Integration ViewModel - Disposing');
    super.dispose();
  }

  void reset() {
    _state = SmsIntegrationState.initial;
    _errorMessage = null;
    _totalMessages = 0;
    _processedMessages = 0;
    _createdWallets = [];
    _importedTransactions = [];
    notifyListeners();
  }
}
