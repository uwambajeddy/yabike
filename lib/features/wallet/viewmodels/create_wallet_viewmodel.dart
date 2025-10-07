import 'package:flutter/foundation.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/models/currency_model.dart';

/// ViewModel for managing wallet creation flow
class CreateWalletViewModel extends ChangeNotifier {
  String _walletName = '';
  CurrencyModel _selectedCurrency = Currencies.rwf;
  double _initialBalance = 0.0;
  WalletType _walletType = WalletType.cash;
  String _accountNumber = '';
  bool _smsIntegrationEnabled = false;

  // Getters
  String get walletName => _walletName;
  CurrencyModel get selectedCurrency => _selectedCurrency;
  double get initialBalance => _initialBalance;
  WalletType get walletType => _walletType;
  String get accountNumber => _accountNumber;
  bool get smsIntegrationEnabled => _smsIntegrationEnabled;

  // Validation
  bool get isWalletNameValid => _walletName.trim().isNotEmpty;
  bool get canProceed => isWalletNameValid;

  // Setters
  void setWalletName(String name) {
    _walletName = name;
    notifyListeners();
  }

  void setSelectedCurrency(CurrencyModel currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void setInitialBalance(double balance) {
    _initialBalance = balance;
    notifyListeners();
  }

  void setWalletType(WalletType type) {
    _walletType = type;
    notifyListeners();
  }

  void setAccountNumber(String number) {
    _accountNumber = number;
    notifyListeners();
  }

  void setSmsIntegrationEnabled(bool enabled) {
    _smsIntegrationEnabled = enabled;
    notifyListeners();
  }

  /// Create the wallet with collected data
  Wallet createWallet() {
    return Wallet(
      id: '', // Will be generated when saving
      name: _walletName,
      type: _walletType.name,
      balance: _initialBalance,
      currency: _selectedCurrency.code,
      provider: _walletType == WalletType.bank ? 'Bank' : null,
      accountNumber: _accountNumber.isNotEmpty ? _accountNumber : null,
      createdAt: DateTime.now(),
    );
  }

  /// Reset the view model
  void reset() {
    _walletName = '';
    _selectedCurrency = Currencies.rwf;
    _initialBalance = 0.0;
    _walletType = WalletType.cash;
    _accountNumber = '';
    _smsIntegrationEnabled = false;
    notifyListeners();
  }
}
