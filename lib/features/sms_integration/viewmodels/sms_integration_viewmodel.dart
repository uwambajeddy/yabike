import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/services/sms_parser_service.dart';
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

  // Getters
  SmsIntegrationState get state => _state;
  String? get errorMessage => _errorMessage;
  int get totalMessages => _totalMessages;
  int get processedMessages => _processedMessages;
  double get progress => _totalMessages > 0 ? _processedMessages / _totalMessages : 0.0;
  List<Wallet> get createdWallets => _createdWallets;
  List<Transaction> get importedTransactions => _importedTransactions;

  /// Request SMS permission from the user
  Future<void> requestSmsPermission(BuildContext context) async {
    try {
      _setState(SmsIntegrationState.requestingPermission);

      final status = await Permission.sms.request();

      if (status.isGranted) {
        _setState(SmsIntegrationState.permissionGranted);
        // Navigate to loading screen and start SMS scan
        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.smsLoading,
            arguments: this, // Pass the viewModel instance
          );
        }
        await scanAndImportSms();
      } else if (status.isDenied) {
        _setState(SmsIntegrationState.permissionDenied);
        _errorMessage = 'SMS permission is required to auto-import transactions';
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
        final body = msg.body?.toUpperCase() ?? '';
        return address.contains('EQUITY') ||
            address.contains('MTNMOMO') ||
            body.contains('EQUITY BANK') ||
            body.contains('MTN MOBILE MONEY');
      }).toList();

      _totalMessages = bankMessages.length;
      _processedMessages = 0;
      notifyListeners();

      if (bankMessages.isEmpty) {
        _setState(SmsIntegrationState.completed);
        return;
      }

      // Parse SMS messages
      _setState(SmsIntegrationState.parsing);
      await _parseSmsMessages(bankMessages);

      // Create wallets
      _setState(SmsIntegrationState.creatingWallets);
      await _createWalletsFromTransactions();

      _setState(SmsIntegrationState.completed);
    } catch (e) {
      _setState(SmsIntegrationState.error);
      _errorMessage = 'Failed to scan SMS messages: $e';
    }
  }

  /// Parse SMS messages into transactions
  Future<void> _parseSmsMessages(List<SmsMessage> messages) async {
    final parsedTransactions = <Transaction>[];

    for (final message in messages) {
      try {
        // Determine source from address or body
        String source = 'UNKNOWN';
        final address = message.address?.toUpperCase() ?? '';
        final body = message.body ?? '';

        if (address.contains('EQUITY') || body.toUpperCase().contains('EQUITY BANK')) {
          source = 'EQUITYBANK';
        } else if (address.contains('MTNMOMO') || body.toUpperCase().contains('MTN MOBILE MONEY')) {
          source = 'MTNMOMO';
        }

        // Parse the message using static method
        Transaction? transaction;
        final messageData = {
          'rawMessage': body,
          'id': 'tx_${DateTime.now().millisecondsSinceEpoch}_${_processedMessages}',
          'date': (message.date ?? DateTime.now()).toIso8601String(),
        };

        if (source == 'EQUITYBANK') {
          transaction = SmsParserService.parseEquityBankSMS(messageData);
        } else if (source == 'MTNMOMO') {
          transaction = SmsParserService.parseMTNMoMoSMS(messageData);
        }

        if (transaction != null) {
          parsedTransactions.add(transaction);
        }

        _processedMessages++;
        notifyListeners();
      } catch (e) {
        // Skip failed parsing
        debugPrint('Failed to parse message: $e');
      }
    }

    _importedTransactions = parsedTransactions;
  }

  /// Create wallets from imported transactions
  Future<void> _createWalletsFromTransactions() async {
    final wallets = <Wallet>[];

    // Group transactions by source
    final equityTransactions = _importedTransactions
        .where((t) => t.source == 'EQUITYBANK')
        .toList();
    final momoTransactions = _importedTransactions
        .where((t) => t.source == 'MTNMOMO')
        .toList();

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
        final updatedTransaction = transaction.copyWith(walletId: equityWallet.id);
        final index = _importedTransactions.indexOf(transaction);
        _importedTransactions[index] = updatedTransaction;
      }

      wallets.add(equityWallet);
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
        final updatedTransaction = transaction.copyWith(walletId: momoWallet.id);
        final index = _importedTransactions.indexOf(transaction);
        _importedTransactions[index] = updatedTransaction;
      }

      wallets.add(momoWallet);
    }

    _createdWallets = wallets;
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
    _state = newState;
    notifyListeners();
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
