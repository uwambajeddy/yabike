import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget_model.dart';

/// Repository for managing budget data in Hive
class BudgetRepository {
  static const String _boxName = 'budgets';

  /// Get the Hive box for budgets
  Box get _box => Hive.box(_boxName);

  /// Get all budgets
  List<Budget> getAllBudgets() {
    try {
      final List<dynamic> budgetsData = _box.values.toList();
      return budgetsData
          .map((data) => Budget.fromJson(Map<String, dynamic>.from(data as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
    } catch (e) {
      return [];
    }
  }

  /// Get active budgets only
  List<Budget> getActiveBudgets() {
    return getAllBudgets().where((budget) => budget.isActive).toList();
  }

  /// Get budgets for a specific category
  List<Budget> getBudgetsByCategory(String category) {
    return getAllBudgets()
        .where((budget) => budget.category == category && budget.isActive)
        .toList();
  }

  /// Get budgets for a specific wallet
  List<Budget> getBudgetsByWallet(String walletId) {
    return getAllBudgets()
        .where((budget) => budget.walletId == walletId && budget.isActive)
        .toList();
  }

  /// Get budget by ID
  Budget? getBudgetById(String id) {
    try {
      final data = _box.get(id);
      if (data != null) {
        return Budget.fromJson(Map<String, dynamic>.from(data as Map));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add a new budget
  Future<void> addBudget(Budget budget) async {
    await _box.put(budget.id, budget.toJson());
  }

  /// Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    final updatedBudget = budget.copyWith(updatedAt: DateTime.now());
    await _box.put(updatedBudget.id, updatedBudget.toJson());
  }

  /// Update budget spent amount
  Future<void> updateBudgetSpent(String budgetId, double spent) async {
    final budget = getBudgetById(budgetId);
    if (budget != null) {
      final updatedBudget = budget.copyWith(
        spent: spent,
        updatedAt: DateTime.now(),
      );
      await _box.put(budgetId, updatedBudget.toJson());
    }
  }

  /// Delete a budget
  Future<void> deleteBudget(String id) async {
    await _box.delete(id);
  }

  /// Archive a budget (soft delete)
  Future<void> archiveBudget(String id) async {
    final budget = getBudgetById(id);
    if (budget != null) {
      final archivedBudget = budget.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, archivedBudget.toJson());
    }
  }

  /// Get total budget amount across all active budgets
  double getTotalBudgetAmount() {
    return getActiveBudgets().fold(0.0, (sum, budget) => sum + budget.amount);
  }

  /// Get total spent across all active budgets
  double getTotalSpent() {
    return getActiveBudgets().fold(0.0, (sum, budget) => sum + budget.spent);
  }

  /// Clear all budgets (for testing/debug)
  Future<void> clearAllBudgets() async {
    await _box.clear();
  }
}
