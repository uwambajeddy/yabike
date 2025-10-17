import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/sms_rescan_service.dart';

enum SortBy { dateNewest, dateOldest, amountHighest, amountLowest, category }

class TransactionsViewModel extends ChangeNotifier {
  final WalletRepository _walletRepository = WalletRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final SmsRescanService _smsRescanService = SmsRescanService();

  bool _isLoading = false;
  bool _isRefreshing = false;
  int _newTransactionsCount = 0;
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  List<Wallet> _wallets = [];
  Map<String, String> _transactionEmojis = {};
  
  // Cached computed values
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<String> _categories = [];
  Map<String, List<Transaction>> _groupedTransactions = {};

  // Filter states
  String? _selectedWalletId;
  String? _selectedCategory;
  String? _selectedType; // 'credit', 'debit', or null for all
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  SortBy _sortBy = SortBy.dateNewest;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  int get newTransactionsCount => _newTransactionsCount;
  List<Transaction> get transactions => _filteredTransactions;
  List<Wallet> get wallets => _wallets;
  String get currency => _wallets.isNotEmpty ? _wallets.first.currency : 'RWF';
  
  // Filter getters
  String? get selectedWalletId => _selectedWalletId;
  String? get selectedCategory => _selectedCategory;
  String? get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  SortBy get sortBy => _sortBy;
  
  bool get hasActiveFilters => 
      _selectedWalletId != null || 
      _selectedCategory != null || 
      _selectedType != null || 
      _startDate != null || 
      _endDate != null ||
      _searchQuery.isNotEmpty;

  // Return cached values instead of computing on every access
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get netBalance => _totalIncome - _totalExpenses;
  List<String> get categories => _categories;
  Map<String, List<Transaction>> get groupedTransactions => _groupedTransactions;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadData();
      _applyFilters();
      
      // Auto-scan for new SMS transactions when opening transactions screen
      debugPrint('🔄 Auto-scanning for new SMS transactions...');
      final newCount = await _smsRescanService.rescanAndImportNewTransactions();
      
      if (newCount > 0) {
        debugPrint('✅ Auto-imported $newCount new transaction(s)!');
        _newTransactionsCount = newCount;
        // Reload transactions to include the new ones
        await _loadData();
        _applyFilters();
      } else {
        debugPrint('✓ No new transactions found');
      }
    } catch (e) {
      debugPrint('Error initializing transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    _wallets = _walletRepository.getActiveWallets();
    _allTransactions = _transactionRepository.getAllTransactions();
    _transactionEmojis = {};
  }

  /// Refresh data and rescan SMS for new transactions
  Future<void> refresh() async {
    _isRefreshing = true;
    _newTransactionsCount = 0;
    notifyListeners();

    try {
      // Rescan SMS messages for new transactions
      final newCount = await _smsRescanService.rescanAndImportNewTransactions();
      _newTransactionsCount = newCount;
      
      // Reload all data
      await _loadData();
      _applyFilters();
      
      if (newCount > 0) {
        debugPrint('Successfully imported $newCount new transactions!');
      }
    } catch (e) {
      debugPrint('❌ Error during refresh: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setWalletFilter(String? walletId) {
    _selectedWalletId = walletId;
    _applyFilters();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setTypeFilter(String? type) {
    _selectedType = type;
    _applyFilters();
  }

  void setDateRangeFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  void setSortBy(SortBy sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void clearFilters() {
    _selectedWalletId = null;
    _selectedCategory = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTransactions = _allTransactions.where((transaction) {
      // Wallet filter
      if (_selectedWalletId != null && transaction.walletId != _selectedWalletId) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null && transaction.category != _selectedCategory) {
        return false;
      }

      // Type filter (income/expense)
      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }

      // Date range filter
      if (_startDate != null && transaction.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && transaction.date.isAfter(_endDate!)) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchableText = [
          transaction.description,
          transaction.category,
          transaction.recipient ?? '',
          transaction.sender ?? '',
          transaction.amount.toString(),
        ].join(' ').toLowerCase();

        if (!searchableText.contains(_searchQuery)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case SortBy.dateNewest:
        _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortBy.dateOldest:
        _filteredTransactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortBy.amountHighest:
        _filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortBy.amountLowest:
        _filteredTransactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortBy.category:
        _filteredTransactions.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    // Compute and cache derived values
    _computeCachedValues();

    notifyListeners();
  }

  /// Compute and cache expensive calculations
  void _computeCachedValues() {
    // Calculate totals
    _totalIncome = 0.0;
    _totalExpenses = 0.0;
    for (final transaction in _filteredTransactions) {
      if (transaction.type == 'credit') {
        _totalIncome += transaction.amount;
      } else {
        _totalExpenses += transaction.amount;
      }
    }

    // Extract categories
    final categorySet = <String>{};
    for (final transaction in _allTransactions) {
      if (transaction.category.isNotEmpty) {
        categorySet.add(transaction.category);
      }
    }
    _categories = categorySet.toList()..sort();

    // Group transactions by date
    _groupedTransactions = {};
    for (final transaction in _filteredTransactions) {
      final dateKey = _formatDateKey(transaction.date);
      if (!_groupedTransactions.containsKey(dateKey)) {
        _groupedTransactions[dateKey] = [];
      }
      _groupedTransactions[dateKey]!.add(transaction);
    }
  }

  String? getWalletName(String? walletId) {
    if (walletId == null) return null;
    try {
      return _wallets.firstWhere((w) => w.id == walletId).name;
    } catch (e) {
      return null;
    }
  }

  String? getTransactionEmoji(String transactionId) {
    return _transactionEmojis[transactionId];
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
      final day = date.day.toString().padLeft(2, '0');
      final month = _getMonthName(date.month);
      return '$day $month ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Map<String, List<Map<String, dynamic>>> getCategoryStats() {
    // Calculate category percentages for income and expenses
    final incomeByCategory = <String, double>{};
    final expensesByCategory = <String, double>{};

    for (final transaction in _filteredTransactions) {
      if (transaction.type == 'credit') {
        incomeByCategory[transaction.category] =
            (incomeByCategory[transaction.category] ?? 0) + transaction.amount;
      } else {
        expensesByCategory[transaction.category] =
            (expensesByCategory[transaction.category] ?? 0) + transaction.amount;
      }
    }

    // Convert to percentages and sort
    final incomeStats = _convertToPercentages(incomeByCategory, _totalIncome);
    final expenseStats = _convertToPercentages(expensesByCategory, _totalExpenses);

    return {
      'income': incomeStats,
      'expenses': expenseStats,
    };
  }

  List<Map<String, dynamic>> _convertToPercentages(
      Map<String, double> categoryTotals, double total) {
    if (total == 0) return [];

    final stats = categoryTotals.entries.map((entry) {
      return {
        'category': entry.key.isEmpty ? 'Uncategorized' : entry.key,
        'amount': entry.value,
        'percentage': (entry.value / total) * 100,
        'color': _getCategoryColor(entry.key),
      };
    }).toList();

    // Sort by amount descending
    stats.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return stats.take(3).toList(); // Top 3 categories
  }

  Color _getCategoryColor(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('food')) return const Color(0xFFFFB74D);
    if (categoryLower.contains('transport')) return const Color(0xFF42A5F5);
    if (categoryLower.contains('shopping')) return const Color(0xFFAB47BC);
    if (categoryLower.contains('investment')) return const Color(0xFF66BB6A);
    return const Color(0xFF78909C);
  }
}
