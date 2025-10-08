import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/services/sms_parser_service.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
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

  // Repository instances
  final WalletRepository _walletRepository = WalletRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

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
  Future<void> scanAndImportSms() async {
    try {
      _setState(SmsIntegrationState.scanning);

      // Get SMS query
      final SmsQuery query = SmsQuery();

      // Fetch all SMS messages
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent],
      );

      // Filter for Equity Bank and MTN MoMo messages
      final bankMessages = messages.where((msg) {
        final address = msg.address?.toUpperCase() ?? '';
        return address.contains('EQUITYBANK') || address.contains('M-MONEY');
      }).toList();

      _totalMessages = bankMessages.length;
      _processedMessages = 0;
      notifyListeners();

      debugPrint('====== SMS SCAN RESULTS ======');
      debugPrint('Total SMS messages scanned: ${messages.length}');
      debugPrint('Bank messages found: ${bankMessages.length}');

      // Log details of each bank message
      for (int i = 0; i < bankMessages.length && i < 10; i++) {
        final msg = bankMessages[i];
        debugPrint('\n--- Message ${i + 1} ---');
        debugPrint('From: ${msg.address}');
        debugPrint('Date: ${msg.date}');
        debugPrint('Body: ${msg.body}');
      }
      if (bankMessages.length > 10) {
        debugPrint('\n... and ${bankMessages.length - 10} more messages');
      }
      debugPrint('==============================\n');

      if (bankMessages.isEmpty) {
        _setState(SmsIntegrationState.completed);
        debugPrint(
          'No bank messages found - SMS import completed with 0 transactions',
        );
        return;
      }

      // Parse SMS messages
      _setState(SmsIntegrationState.parsing);
      await _parseSmsMessages(bankMessages);

      // Create wallets and save to Hive
      _setState(SmsIntegrationState.creatingWallets);
      await _createWalletsFromTransactions();

      debugPrint('⚡ SMS Import completed - ${_createdWallets.length} wallets, ${_importedTransactions.length} transactions');
      _setState(SmsIntegrationState.completed);
    } catch (e, stackTrace) {
      // Only set error state if we haven't already completed
      if (_state != SmsIntegrationState.completed && !_isDisposed) {
        debugPrint('❌❌❌ CRITICAL ERROR IN SMS IMPORT ❌❌❌');
        debugPrint('Error: $e');
        debugPrint('Stack trace: $stackTrace');
        _setState(SmsIntegrationState.error);
        _errorMessage = 'Failed to scan SMS messages: $e';
      } else {
        debugPrint('⚠️ Error occurred after completion/disposal - ignoring: $e');
      }
    }
  }

  /// Parse SMS messages into transactions
  Future<void> _parseSmsMessages(List<SmsMessage> messages) async {
    final parsedTransactions = <Transaction>[];

    debugPrint('\n====== PARSING SMS MESSAGES ======');

    for (final message in messages) {
      try {
        final address = message.address ?? '';
        final body = message.body ?? '';
        final date = message.date ?? DateTime.now();

        // Use the new parseSms method which includes filtering
        final transaction = SmsParserService.parseSms(body, address, date);

        if (transaction != null) {
          parsedTransactions.add(transaction);
         
        } 

        _processedMessages++;
        notifyListeners();
      } catch (e) {
        // Skip failed parsing
        debugPrint('❌ Exception while parsing: $e');
      }
    }

    _importedTransactions = parsedTransactions;
    debugPrint('\n====== PARSING COMPLETE ======');
    debugPrint('Total transactions parsed: ${parsedTransactions.length}');
    debugPrint(
      'Equity Bank: ${parsedTransactions.where((t) => t.source == 'EQUITYBANK').length}',
    );
    debugPrint(
      'MTN MoMo: ${parsedTransactions.where((t) => t.source == 'M-MONEY').length}',
    );
    debugPrint('==============================\n');
  }

  /// Create wallets from imported transactions
  Future<void> _createWalletsFromTransactions() async {
    try {
      debugPrint('\n====== CREATING WALLETS ======');
      final wallets = <Wallet>[];

      // Group transactions by source
      final equityTransactions = _importedTransactions
          .where((t) => t.source == 'EQUITYBANK')
          .toList();
      final momoTransactions = _importedTransactions
          .where((t) => t.source == 'M-MONEY')
          .toList();
      
      debugPrint('Equity transactions: ${equityTransactions.length}');
      debugPrint('MoMo transactions: ${momoTransactions.length}');

    // Create Equity Bank wallet if there are transactions
    if (equityTransactions.isNotEmpty) {
      // Calculate balance from transactions (sum of credits - debits)
      double balance = 0.0;
      for (final transaction in equityTransactions) {
        if (transaction.type == 'credit') {
          balance += transaction.amountRWF;
        } else {
          balance -= transaction.amountRWF;
        }
      }

      final equityWallet = Wallet(
        name: 'Equity Bank',
        type: 'bank',
        provider: 'EquityBank',
        currency: 'RWF',
        balance: balance,
        createdAt: DateTime.now(),
      );

      // Assign wallet ID to transactions
      for (final transaction in equityTransactions) {
        final updatedTransaction = transaction.copyWith(
          walletId: equityWallet.id,
        );
        final index = _importedTransactions.indexOf(transaction);
        _importedTransactions[index] = updatedTransaction;
      }

      wallets.add(equityWallet);

      // Save wallet to Hive
      await _walletRepository.addWallet(equityWallet);
    }

    // Create MTN MoMo wallet if there are transactions
    if (momoTransactions.isNotEmpty) {
      // Use the most recent balance from transaction messages
      double balance = 0.0;
      momoTransactions.sort((a, b) => b.date.compareTo(a.date));

      for (final transaction in momoTransactions) {
        if (transaction.balanceRWF != null && transaction.balanceRWF! > 0) {
          balance = transaction.balanceRWF!;
          break;
        }
      }

      // If no balance found in messages, calculate from transactions
      if (balance == 0.0) {
        for (final transaction in momoTransactions) {
          if (transaction.type == 'credit') {
            balance += transaction.amountRWF;
          } else {
            balance -= transaction.amountRWF;
          }
        }
      }

      final momoWallet = Wallet(
        name: 'MTN Mobile Money',
        type: 'momo',
        provider: 'MTN',
        currency: 'RWF',
        balance: balance,
        createdAt: DateTime.now(),
      );

      // Assign wallet ID to transactions
      for (final transaction in momoTransactions) {
        final updatedTransaction = transaction.copyWith(
          walletId: momoWallet.id,
        );
        final index = _importedTransactions.indexOf(transaction);
        _importedTransactions[index] = updatedTransaction;
      }

      wallets.add(momoWallet);

      // Save wallet to Hive
      await _walletRepository.addWallet(momoWallet);
    }

    _createdWallets = wallets;

    // Save all transactions to Hive
    if (_importedTransactions.isNotEmpty) {
      await _transactionRepository.addTransactions(_importedTransactions);
      debugPrint(
        'Successfully saved ${_importedTransactions.length} transactions to Hive',
      );
    }
    
    debugPrint('✅ Wallet creation completed successfully');
    debugPrint('==============================\n');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in _createWalletsFromTransactions: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

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
