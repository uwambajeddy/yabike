import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/wallet_repository.dart';

enum TransactionType { expense, income }

class AddTransactionViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final WalletRepository _walletRepository = WalletRepository();

  // Form state
  double _amount = 0.0;
  TransactionType? _type;
  String _category = '';
  String _description = '';
  DateTime _date = DateTime.now();
  Wallet? _selectedWallet;
  String? _note;
  String? _receiptPath;
  
  // Wallets
  List<Wallet> _wallets = [];
  
  // Categories (can be expanded or loaded from a service)
  final List<String> expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Personal Care',
    'Gifts & Donations',
    'Other',
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investments',
    'Gifts',
    'Refunds',
    'Other',
  ];

  // Getters
  double get amount => _amount;
  TransactionType? get type => _type;
  String get category => _category;
  String get description => _description;
  DateTime get date => _date;
  Wallet? get selectedWallet => _selectedWallet;
  String? get note => _note;
  String? get receiptPath => _receiptPath;
  List<Wallet> get wallets => _wallets;
  
  List<String> get categories =>
      _type == TransactionType.expense ? expenseCategories : incomeCategories;

  bool get canProceed => _amount > 0 && _selectedWallet != null;
  bool get canSave =>
      _amount > 0 && _category.isNotEmpty && _selectedWallet != null;

  /// Initialize - load wallets
  Future<void> initialize() async {
    _wallets = _walletRepository.getActiveWallets();
    if (_wallets.isNotEmpty && _selectedWallet == null) {
      _selectedWallet = _wallets.first;
    }
    notifyListeners();
  }

  /// Set amount
  void setAmount(double value) {
    _amount = value;
    notifyListeners();
  }

  /// Toggle transaction type
  void setType(TransactionType type) {
    _type = type;
    // Reset category when type changes
    _category = '';
    notifyListeners();
  }

  /// Select category
  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  /// Set description
  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  /// Set date
  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  /// Select wallet
  void setWallet(Wallet wallet) {
    _selectedWallet = wallet;
    notifyListeners();
  }

  /// Set note
  void setNote(String? value) {
    _note = value;
    notifyListeners();
  }

  /// Set receipt path
  void setReceiptPath(String? path) {
    _receiptPath = path;
    notifyListeners();
  }

  /// Save transaction
  Future<bool> saveTransaction() async {
    if (!canSave || _type == null) return false;

    try {
      final transaction = Transaction(
        date: _date,
        source: _selectedWallet!.provider ?? 'Manual',
        rawMessage: _note ?? '',
        type: _type == TransactionType.income ? 'credit' : 'debit',
        category: _category,
        amount: _amount,
        currency: _selectedWallet!.currency,
        amountRWF: _selectedWallet!.currency == 'RWF'
            ? _amount
            : _amount * 1440, // Convert USD to RWF
        description: _description,
        walletId: _selectedWallet!.id,
      );

      await _transactionRepository.addTransaction(transaction);

      // Update wallet balance
      final newBalance = _type == TransactionType.income
          ? _selectedWallet!.balance + _amount
          : _selectedWallet!.balance - _amount;
      
      await _walletRepository.updateWallet(
        _selectedWallet!.copyWith(balance: newBalance),
      );

      return true;
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      return false;
    }
  }

  /// Reset form
  void reset() {
    _amount = 0.0;
    _type = null;
    _category = '';
    _description = '';
    _date = DateTime.now();
    _note = null;
    _receiptPath = null;
    notifyListeners();
  }
}
