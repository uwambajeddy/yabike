import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

/// Repository for transaction data access
class TransactionRepository {
  static const String _transactionsBoxName = 'transactions';
  
  /// Get the transactions box
  Box get _transactionsBox => Hive.box(_transactionsBoxName);
  
  /// Initialize the transactions box (not needed - opened in main.dart)
  static Future<void> init() async {
    // Box is already opened in main.dart
  }
  
  /// Get all transactions
  List<Transaction> getAllTransactions() {
    if (_transactionsBox.isEmpty) return [];
    
    return _transactionsBox.values
        .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }
  
  /// Get transactions for specific wallet
  List<Transaction> getTransactionsByWallet(String walletId) {
    return getAllTransactions()
        .where((transaction) => transaction.walletId == walletId)
        .toList();
  }
  
  /// Get recent transactions (limit)
  List<Transaction> getRecentTransactions({int limit = 10}) {
    final transactions = getAllTransactions();
    return transactions.take(limit).toList();
  }
  
  /// Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return getAllTransactions()
        .where((transaction) =>
            transaction.date.isAfter(start) &&
            transaction.date.isBefore(end))
        .toList();
  }
  
  /// Get transactions by category
  List<Transaction> getTransactionsByCategory(String category) {
    return getAllTransactions()
        .where((transaction) => transaction.category == category)
        .toList();
  }
  
  /// Get transactions by type (credit/debit)
  List<Transaction> getTransactionsByType(String type) {
    return getAllTransactions()
        .where((transaction) => transaction.type == type)
        .toList();
  }
  
  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction.toJson());
  }
  
  /// Add multiple transactions (for SMS import)
  Future<void> addTransactions(List<Transaction> transactions) async {
    final Map<String, dynamic> transactionsMap = {
      for (var transaction in transactions) 
        transaction.id: transaction.toJson()
    };
    await _transactionsBox.putAll(transactionsMap);
  }
  
  /// Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction.toJson());
  }
  
  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }
  
  /// Clear all transactions (useful for re-importing)
  Future<void> clearAllTransactions() async {
    await _transactionsBox.clear();
  }
  
  /// Get total income
  double getTotalIncome({String? walletId, DateTime? start, DateTime? end}) {
    var transactions = walletId != null
        ? getTransactionsByWallet(walletId)
        : getAllTransactions();
    
    if (start != null && end != null) {
      transactions = transactions.where((t) =>
          t.date.isAfter(start) && t.date.isBefore(end)).toList();
    }
    
    return transactions
        .where((t) => t.type == 'credit')
        .fold(0.0, (sum, t) => sum + t.amountRWF);
  }
  
  /// Get total expenses
  double getTotalExpenses({String? walletId, DateTime? start, DateTime? end}) {
    var transactions = walletId != null
        ? getTransactionsByWallet(walletId)
        : getAllTransactions();
    
    if (start != null && end != null) {
      transactions = transactions.where((t) =>
          t.date.isAfter(start) && t.date.isBefore(end)).toList();
    }
    
    return transactions
        .where((t) => t.type == 'debit')
        .fold(0.0, (sum, t) => sum + t.amountRWF);
  }
  
  /// Get transactions grouped by date
  Map<String, List<Transaction>> getTransactionsGroupedByDate() {
    final transactions = getAllTransactions();
    final Map<String, List<Transaction>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = _formatDateKey(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }
    
    return grouped;
  }
  
  /// Get today's transactions
  List<Transaction> getTodayTransactions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return getTransactionsByDateRange(startOfDay, endOfDay);
  }
  
  /// Get this month's transactions
  List<Transaction> getMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }
  
  /// Format date for grouping
  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  /// Check if any transactions exist
  bool hasTransactions() {
    return _transactionsBox.isNotEmpty;
  }
  
  /// Listen to transaction changes
  Stream<List<Transaction>> watchTransactions() {
    return _transactionsBox.watch().map((event) => getAllTransactions());
  }
  
  /// Close the box
  Future<void> close() async {
    await _transactionsBox.close();
  }
}
