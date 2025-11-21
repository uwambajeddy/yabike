import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/security_service.dart';
import '../../../core/services/receipt_scanner_service.dart';
import 'package:image_picker/image_picker.dart';

enum TransactionType { expense, income }

class AddTransactionViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final WalletRepository _walletRepository = WalletRepository();
  final CategoryService _categoryService = CategoryService.instance;

  // Form state
  double _amount = 0.0;
  TransactionType? _type;
  Category? _selectedCategory;
  String _description = '';
  DateTime _date = DateTime.now();
  Wallet? _selectedWallet;
  String? _note;
  String? _receiptPath;
  Transaction? _editingTransaction;
  
  // Wallets
  List<Wallet> _wallets = [];
  
  // Categories
  List<Category> _categories = [];

  // Getters
  double get amount => _amount;
  TransactionType? get type => _type;
  Category? get selectedCategory => _selectedCategory;
  String get description => _description;
  DateTime get date => _date;
  Wallet? get selectedWallet => _selectedWallet;
  String? get note => _note;
  String? get receiptPath => _receiptPath;
  List<Wallet> get wallets => _wallets;
  List<Category> get categories => _categories;
  
  List<Category> get filteredCategories {
    if (_type == null) return [];
    return _categories.where((c) => c.type == (_type == TransactionType.expense ? CategoryType.expense : CategoryType.income)).toList();
  }

  bool get canProceed => _amount > 0 && _selectedWallet != null;
  bool get canSave =>
      _amount > 0 && _selectedCategory != null && _selectedWallet != null;

  /// Initialize - load wallets and categories
  Future<void> initialize([Transaction? transaction]) async {
    _editingTransaction = transaction;
    _wallets = _walletRepository.getActiveWallets();
    await _categoryService.initialize();
    _categories = _categoryService.categories;
    
    if (transaction != null) {
      // Pre-fill with transaction data
      _amount = transaction.amount;
      _type = transaction.type == 'credit' ? TransactionType.income : TransactionType.expense;
      _description = transaction.description;
      _date = transaction.date;
      _note = transaction.rawMessage;
      
      // Find and set wallet
      _selectedWallet = _wallets.firstWhere(
        (w) => w.id == transaction.walletId,
        orElse: () => _wallets.isNotEmpty ? _wallets.first : _wallets.first,
      );
      
      // Find and set category
      _selectedCategory = _categories.firstWhere(
        (c) => c.name == transaction.category,
        orElse: () => _categories.first,
      );
    } else {
      if (_wallets.isNotEmpty && _selectedWallet == null) {
        _selectedWallet = _wallets.first;
      }
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
    _selectedCategory = null;
    notifyListeners();
  }

  /// Select category
  void setCategory(Category category) {
    _selectedCategory = category;
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
      if (_editingTransaction != null) {
        // Edit mode - update existing transaction
        final oldTransaction = _editingTransaction!;
        final oldAmount = oldTransaction.amount;
        final oldType = oldTransaction.type;
        
        // Revert old transaction's effect on wallet balance
        final oldWallet = _wallets.firstWhere((w) => w.id == oldTransaction.walletId);
        final revertedBalance = oldType == 'credit'
            ? oldWallet.balance - oldAmount
            : oldWallet.balance + oldAmount;
        
        final updatedTransaction = oldTransaction.copyWith(
          date: _date,
          type: _type == TransactionType.income ? 'credit' : 'debit',
          category: _selectedCategory!.name,
          amount: _amount,
          currency: _selectedWallet!.currency,
          description: _description,
          walletId: _selectedWallet!.id,
          rawMessage: _note ?? '',
        );
        
        await _transactionRepository.updateTransaction(updatedTransaction);
        
        // Apply new transaction's effect on wallet balance
        final newBalance = _type == TransactionType.income
            ? revertedBalance + _amount
            : revertedBalance - _amount;
        
        await _walletRepository.updateWallet(
          _selectedWallet!.copyWith(balance: newBalance),
        );
      } else {
        // Add mode - create new transaction
        final transaction = Transaction(
          date: _date,
          source: _selectedWallet!.provider ?? 'Manual',
          rawMessage: _note ?? '',
          type: _type == TransactionType.income ? 'credit' : 'debit',
          category: _selectedCategory!.name,
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
      }

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
    _selectedCategory = null;
    _description = '';
    _date = DateTime.now();
    _note = null;
    _receiptPath = null;
    notifyListeners();
  }

  // Receipt Scanning
  final ReceiptScannerService _receiptScanner = ReceiptScannerService();
  final SecurityService _securityService = SecurityService();
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Future<void> scanReceipt(ImageSource source) async {
    _setScanning(true);
    _securityService.pauseSecurity();
    try {
      final data = source == ImageSource.camera 
          ? await _receiptScanner.scanReceiptFromCamera()
          : await _receiptScanner.scanReceiptFromGallery();
      
      if (data != null) {
        // Apply data directly to form
        _applyReceiptData(data);
        
        // Store confidence and error for UI feedback
        _lastScanConfidence = data.confidence;
        _lastScanError = data.errorMessage;
        notifyListeners();
      }
    } finally {
      _securityService.resumeSecurity();
      _setScanning(false);
    }
  }

  double? _lastScanConfidence;
  String? _lastScanError;
  
  double? get lastScanConfidence => _lastScanConfidence;
  String? get lastScanError => _lastScanError;
  
  void clearScanFeedback() {
    _lastScanConfidence = null;
    _lastScanError = null;
    notifyListeners();
  }

  void _setScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  void _applyReceiptData(ReceiptData data) {
    debugPrint('Applying receipt data: $data');
    if (data.amount != null) {
      _amount = data.amount!;
      debugPrint('Set amount: $_amount');
    }
    if (data.date != null) {
      _date = data.date!;
      debugPrint('Set date: $_date');
    }
    if (data.merchantName != null) {
      _description = data.merchantName!;
      debugPrint('Set description: $_description');
    }
    // Auto-select expense if not set
    if (_type == null) {
      _type = TransactionType.expense;
      debugPrint('Auto-selected expense type');
    }
    notifyListeners();
    debugPrint('Receipt data applied successfully');
  }

  @override
  void dispose() {
    _receiptScanner.dispose();
    super.dispose();
  }
}
