import 'package:flutter/material.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/wallet_repository.dart';

class AddBudgetViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepository = BudgetRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final WalletRepository _walletRepository = WalletRepository();

  bool _isLoading = false;
  bool _showValidation = false;
  String? _selectedCategory;
  String _selectedPeriod = 'monthly';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedWallet;

  List<String> _categories = [];
  List<String> _wallets = [];

  bool get isLoading => _isLoading;
  bool get showValidation => _showValidation;
  String? get selectedCategory => _selectedCategory;
  String get selectedPeriod => _selectedPeriod;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedWallet => _selectedWallet;
  List<String> get categories => _categories;
  List<String> get wallets => _wallets;

  AddBudgetViewModel() {
    _loadCategories();
    _loadWallets();
    _setDefaultDates();
  }

  void _loadCategories() {
    final transactions = _transactionRepository.getAllTransactions();
    final categorySet = <String>{};
    
    for (final transaction in transactions) {
      if (transaction.category.isNotEmpty) {
        categorySet.add(transaction.category);
      }
    }

    _categories = categorySet.toList()..sort();
    
    // Add some default categories if none exist
    if (_categories.isEmpty) {
      _categories = [
        'Food & Dining',
        'Transportation',
        'Shopping',
        'Entertainment',
        'Bills & Utilities',
        'Healthcare',
        'Education',
        'Others',
      ];
    }
    
    notifyListeners();
  }

  void _loadWallets() {
    final allWallets = _walletRepository.getAllWallets();
    _wallets = allWallets.map((w) => w.name).toList();
    notifyListeners();
  }

  void _setDefaultDates() {
    // Default to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0); // Last day of month
    notifyListeners();
  }

  void initializeForEdit(Budget budget) {
    _selectedCategory = budget.category;
    _selectedPeriod = budget.period;
    _startDate = budget.startDate;
    _endDate = budget.endDate;
    
    if (budget.walletId != null) {
      final wallet = _walletRepository.getWalletById(budget.walletId!);
      _selectedWallet = wallet?.name;
    }
    
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    _updateDatesBasedOnPeriod();
    notifyListeners();
  }

  void _updateDatesBasedOnPeriod() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'daily':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'weekly':
        // Start from Monday of current week
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        _startDate = DateTime(monday.year, monday.month, monday.day);
        _endDate = _startDate!.add(const Duration(days: 6));
        break;
      case 'monthly':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'yearly':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
    }
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    
    // Auto-adjust end date based on period if needed
    if (_endDate == null || _endDate!.isBefore(_startDate!)) {
      switch (_selectedPeriod) {
        case 'daily':
          _endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
          break;
        case 'weekly':
          _endDate = date.add(const Duration(days: 6));
          break;
        case 'monthly':
          _endDate = DateTime(date.year, date.month + 1, 0);
          break;
        case 'yearly':
          _endDate = DateTime(date.year, 12, 31);
          break;
      }
    }
    
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void setWallet(String? walletName) {
    _selectedWallet = walletName;
    notifyListeners();
  }

  void setShowValidation(bool value) {
    _showValidation = value;
    notifyListeners();
  }

  Future<bool> saveBudget({
    required String name,
    required double amount,
    String? existingBudgetId,
  }) async {
    if (_selectedCategory == null || _startDate == null || _endDate == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get wallet ID if wallet is selected
      String? walletId;
      if (_selectedWallet != null) {
        final wallet = _walletRepository.getAllWallets().firstWhere(
          (w) => w.name == _selectedWallet,
          orElse: () => _walletRepository.getAllWallets().first,
        );
        walletId = wallet.id;
      }

      if (existingBudgetId != null) {
        // Update existing budget
        final existingBudget = await _budgetRepository.getBudgetById(existingBudgetId);
        if (existingBudget != null) {
          final updatedBudget = existingBudget.copyWith(
            name: name,
            category: _selectedCategory!,
            amount: amount,
            period: _selectedPeriod,
            startDate: _startDate!,
            endDate: _endDate!,
            walletId: walletId,
          );
          await _budgetRepository.updateBudget(updatedBudget);
        }
      } else {
        // Create new budget
        final budget = Budget(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          category: _selectedCategory!,
          amount: amount,
          spent: 0, // Will be calculated later
          period: _selectedPeriod,
          startDate: _startDate!,
          endDate: _endDate!,
          walletId: walletId,
          isActive: true,
        );
        
        await _budgetRepository.addBudget(budget);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving budget: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
