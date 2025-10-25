import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../../core/constants/app_colors.dart';

/// Service for managing global categories
class CategoryService {
  static const String _categoriesKey = 'global_categories';
  static CategoryService? _instance;
  static CategoryService get instance => _instance ??= CategoryService._();
  
  CategoryService._();

  List<Category> _categories = [];
  bool _initialized = false;

  /// Get all categories
  List<Category> get categories => List.unmodifiable(_categories);

  /// Get expense categories only
  List<Category> get expenseCategories => 
      _categories.where((c) => c.type == CategoryType.expense).toList();

  /// Get income categories only
  List<Category> get incomeCategories => 
      _categories.where((c) => c.type == CategoryType.income).toList();

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by name
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Initialize with default categories
  Future<void> initialize() async {
    if (_initialized) return;

    await _loadCategories();
    
    // If no categories exist, create default ones
    if (_categories.isEmpty) {
      await _createDefaultCategories();
    }
    
    _initialized = true;
  }

  /// Load categories from storage
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_categoriesKey);
      
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        _categories = categoriesList
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = [];
    }
  }

  /// Save categories to storage
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(
        _categories.map((category) => category.toJson()).toList(),
      );
      await prefs.setString(_categoriesKey, categoriesJson);
    } catch (e) {
      debugPrint('Error saving categories: $e');
    }
  }

  /// Create default categories
  Future<void> _createDefaultCategories() async {
    final now = DateTime.now();
    
    _categories = [
      // Expense Categories
      Category(
        id: 'food_dining',
        name: 'Food & Dining',
        description: 'Restaurants, groceries, and food expenses',
        icon: Icons.restaurant,
        color: AppColors.categoryFood,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'transport',
        name: 'Transport',
        description: 'Fuel, public transport, and vehicle expenses',
        icon: Icons.directions_car,
        color: AppColors.categoryTransport,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        description: 'Clothing, electronics, and general shopping',
        icon: Icons.shopping_bag,
        color: AppColors.categoryShopping,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        description: 'Movies, games, and entertainment activities',
        icon: Icons.movie,
        color: AppColors.categoryEntertainment,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'health',
        name: 'Health',
        description: 'Medical expenses and healthcare',
        icon: Icons.local_hospital,
        color: AppColors.categoryHealth,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'education',
        name: 'Education',
        description: 'School fees, books, and educational expenses',
        icon: Icons.school,
        color: AppColors.categoryEducation,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'utilities',
        name: 'Utilities',
        description: 'Electricity, water, internet, and bills',
        icon: Icons.lightbulb,
        color: AppColors.categoryUtilities,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'travel',
        name: 'Travel',
        description: 'Vacation, business trips, and travel expenses',
        icon: Icons.flight,
        color: AppColors.primary500,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'others_expense',
        name: 'Others',
        description: 'Miscellaneous and uncategorized expenses',
        icon: Icons.category,
        color: AppColors.categoryOthers,
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
      ),
      
      // Income Categories
      Category(
        id: 'salary',
        name: 'Salary',
        description: 'Monthly salary and wages',
        icon: Icons.work,
        color: AppColors.success,
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'business',
        name: 'Business',
        description: 'Business income and profits',
        icon: Icons.business,
        color: AppColors.lightGreen,
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'investments',
        name: 'Investments',
        description: 'Investment returns and dividends',
        icon: Icons.trending_up,
        color: AppColors.primary,
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'gifts',
        name: 'Gifts',
        description: 'Gifts and donations received',
        icon: Icons.card_giftcard,
        color: AppColors.primary400,
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'refunds',
        name: 'Refunds',
        description: 'Refunds and reimbursements',
        icon: Icons.reply,
        color: AppColors.primary300,
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'others_income',
        name: 'Others',
        description: 'Other sources of income',
        icon: Icons.add_circle,
        color: AppColors.primary200,
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
      ),
    ];

    await _saveCategories();
  }

  /// Add a new category
  Future<bool> addCategory(Category category) async {
    try {
      // Check if category with same name already exists
      if (getCategoryByName(category.name) != null) {
        return false;
      }

      _categories.add(category);
      await _saveCategories();
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  /// Update an existing category
  Future<bool> updateCategory(Category updatedCategory) async {
    try {
      final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
      if (index == -1) return false;

      // Check if another category with same name exists (excluding current one)
      final existingCategory = getCategoryByName(updatedCategory.name);
      if (existingCategory != null && existingCategory.id != updatedCategory.id) {
        return false;
      }

      _categories[index] = updatedCategory.copyWith(updatedAt: DateTime.now());
      await _saveCategories();
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final category = getCategoryById(categoryId);
      if (category == null || category.isDefault) {
        return false; // Cannot delete default categories
      }

      _categories.removeWhere((c) => c.id == categoryId);
      await _saveCategories();
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  /// Reset to default categories (removes all custom categories)
  Future<void> resetToDefaults() async {
    try {
      _categories = _categories.where((c) => c.isDefault).toList();
      await _saveCategories();
    } catch (e) {
      debugPrint('Error resetting categories: $e');
    }
  }

  /// Get category statistics (placeholder for future implementation)
  Map<String, dynamic> getCategoryStats(String categoryId) {
    // TODO: Implement category statistics
    return {
      'totalTransactions': 0,
      'totalAmount': 0.0,
      'lastUsed': null,
    };
  }
}
