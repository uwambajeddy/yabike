import 'package:flutter/material.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class CreateBudgetStepperViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepository = BudgetRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  int _currentStep = 0;
  String? _budgetName;
  String? _selectedCategory;
  double _budgetAmount = 0;
  DateTime? _endDate;
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];

  // Getters
  int get currentStep => _currentStep;
  String? get budgetName => _budgetName;
  String? get selectedCategory => _selectedCategory;
  double get budgetAmount => _budgetAmount;
  DateTime? get endDate => _endDate;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get categories => _categories;

  // Category icon mapping
  final Map<String, IconData> _categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills & Utilities': Icons.receipt_long,
    'Healthcare': Icons.local_hospital,
    'Education': Icons.school,
    'Personal Care': Icons.self_improvement,
    'Gifts & Donations': Icons.card_giftcard,
    'Travel': Icons.flight,
    'Salary': Icons.attach_money,
    'Business': Icons.business,
    'Investments': Icons.trending_up,
    'Other': Icons.category,
  };

  // Category color mapping
  final Map<String, Color> _categoryColors = {
    'Food & Dining': const Color(0xFFFF6B6B),
    'Transportation': const Color(0xFF4ECDC4),
    'Shopping': const Color(0xFFFFD93D),
    'Entertainment': const Color(0xFFB565A7),
    'Bills & Utilities': const Color(0xFF6BCF7F),
    'Healthcare': const Color(0xFFFF8C42),
    'Education': const Color(0xFF5E60CE),
    'Personal Care': const Color(0xFFFF6BB5),
    'Gifts & Donations': const Color(0xFFD4A574),
    'Travel': const Color(0xFF00B4D8),
    'Salary': const Color(0xFF06D6A0),
    'Business': const Color(0xFF118AB2),
    'Investments': const Color(0xFF073B4C),
    'Other': const Color(0xFF95A5A6),
  };

  CreateBudgetStepperViewModel() {
    _loadCategories();
  }

  void _loadCategories() {
    // Get unique categories from transactions
    final transactions = _transactionRepository.getAllTransactions();
    final uniqueCategories = <String>{};
    
    for (final transaction in transactions) {
      if (transaction.category.isNotEmpty) {
        uniqueCategories.add(transaction.category);
      }
    }

    // Convert to list of maps with icons and colors
    _categories = uniqueCategories.map((category) {
      return <String, dynamic>{
        'name': category,
        'icon': _categoryIcons[category] ?? Icons.category,
        'color': _categoryColors[category] ?? const Color(0xFF95A5A6),
      };
    }).toList();

    // Add "Add New" option at the end
    _categories.add(<String, dynamic>{
      'name': 'Add New',
      'icon': Icons.add_circle_outline,
      'color': const Color(0xFF95A5A6),
      'isAddNew': true,
    });

    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addNewCategory(String categoryName) {
    // Check if category already exists
    final exists = _categories.any((cat) => 
      cat['name'].toString().toLowerCase() == categoryName.toLowerCase() && 
      cat['isAddNew'] != true
    );
    
    if (!exists) {
      // Remove "Add New" temporarily
      final addNewItem = _categories.removeLast();
      
      // Add new category
      _categories.add(<String, dynamic>{
        'name': categoryName,
        'icon': Icons.category,
        'color': const Color(0xFF95A5A6),
      });
      
      // Add back "Add New" at the end
      _categories.add(addNewItem);
      
      // Select the newly added category
      _selectedCategory = categoryName;
      notifyListeners();
    }
  }

  void setBudgetName(String name) {
    _budgetName = name.trim().isEmpty ? null : name.trim();
    notifyListeners();
  }

  void setBudgetAmount(double amount) {
    _budgetAmount = amount;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  bool canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedCategory != null && _budgetName != null && _budgetName!.isNotEmpty;
      case 1:
        return _budgetAmount > 0 && _endDate != null;
      case 2:
        return _budgetAmount > 0 && _endDate != null;
      default:
        return false;
    }
  }

  double calculateDailySavings() {
    if (_budgetAmount <= 0 || _endDate == null) return 0;
    
    final now = DateTime.now();
    final daysUntilGoal = _endDate!.difference(now).inDays;
    
    if (daysUntilGoal <= 0) return _budgetAmount;
    
    return _budgetAmount / daysUntilGoal;
  }

  Future<bool> createBudget() async {
    if (!canProceedToNextStep()) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final budget = Budget(
        name: _budgetName!,
        category: _selectedCategory!,
        amount: _budgetAmount,
        spent: 0,
        period: 'custom',
        startDate: DateTime.now(),
        endDate: _endDate!,
      );

      await _budgetRepository.addBudget(budget);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
