import 'package:flutter/material.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepository = BudgetRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  bool _isLoading = false;
  List<Budget> _budgets = [];

  bool get isLoading => _isLoading;
  List<Budget> get budgets => _budgets;
  
  bool get hasBudgets => _budgets.isNotEmpty;
  
  double get totalBudgetAmount => _budgetRepository.getTotalBudgetAmount();
  double get totalSpent => _budgetRepository.getTotalSpent();
  double get totalRemaining => totalBudgetAmount - totalSpent;
  double get overallPercentage => totalBudgetAmount > 0 
      ? (totalSpent / totalBudgetAmount * 100).clamp(0, 100) 
      : 0;

  /// Initialize and load budgets
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadBudgets();
      await _updateBudgetSpending();
    } catch (e) {
      debugPrint('Error initializing budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all budgets from repository
  Future<void> _loadBudgets() async {
    _budgets = _budgetRepository.getActiveBudgets();
  }

  /// Update budget spending based on transactions
  Future<void> _updateBudgetSpending() async {
    for (final budget in _budgets) {
      // Get transactions within budget period
      final transactions = _transactionRepository
          .getAllTransactions()
          .where((t) => 
              t.type == 'debit' && // Only expenses
              t.category == budget.category &&
              t.date.isAfter(budget.startDate) &&
              t.date.isBefore(budget.endDate))
          .toList();

      // Calculate total spent
      final spent = transactions.fold(0.0, (sum, t) => sum + t.amountRWF);

      // Update if different
      if (spent != budget.spent) {
        await _budgetRepository.updateBudgetSpent(budget.id, spent);
      }
    }

    // Reload budgets after update
    await _loadBudgets();
  }

  /// Refresh budgets
  Future<void> refresh() async {
    await initialize();
  }

  /// Add a new budget
  Future<void> addBudget(Budget budget) async {
    await _budgetRepository.addBudget(budget);
    await refresh();
  }

  /// Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    await _budgetRepository.updateBudget(budget);
    await refresh();
  }

  /// Delete a budget
  Future<void> deleteBudget(String id) async {
    await _budgetRepository.deleteBudget(id);
    await refresh();
  }

  /// Archive a budget
  Future<void> archiveBudget(String id) async {
    await _budgetRepository.archiveBudget(id);
    await refresh();
  }

  /// Get budget by ID
  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get budgets by status
  List<Budget> getBudgetsByStatus(String status) {
    return _budgets.where((b) => b.status == status).toList();
  }

  /// Get exceeded budgets
  List<Budget> getExceededBudgets() {
    return _budgets.where((b) => b.isExceeded).toList();
  }

  /// Get near limit budgets (>80%)
  List<Budget> getNearLimitBudgets() {
    return _budgets.where((b) => b.percentageUsed >= 80 && !b.isExceeded).toList();
  }
}
