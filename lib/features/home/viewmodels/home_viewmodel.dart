import 'package:flutter/material.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final WalletRepository _walletRepository = WalletRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  List<Wallet> _wallets = [];
  List<Transaction> _recentTransactions = [];
  Wallet? _selectedWallet; // null means "All Wallets"
  bool _isLoading = true;

  // Getters
  List<Wallet> get wallets => _wallets;
  List<Transaction> get recentTransactions => _recentTransactions;
  Wallet? get selectedWallet => _selectedWallet;
  bool get isLoading => _isLoading;
  bool get hasWallets => _wallets.isNotEmpty;
  bool get hasTransactions => _recentTransactions.isNotEmpty;

  /// Get total balance (all wallets or selected wallet)
  double get totalBalance {
    if (_selectedWallet != null) {
      return _selectedWallet!.balance;
    }
    return _walletRepository.getTotalBalance();
  }

  /// Get total income (all wallets or selected wallet)
  double get totalIncome {
    return _transactionRepository.getTotalIncome(
      walletId: _selectedWallet?.id,
    );
  }

  /// Get total expenses (all wallets or selected wallet)
  double get totalExpenses {
    return _transactionRepository.getTotalExpenses(
      walletId: _selectedWallet?.id,
    );
  }

  /// Get net balance (income - expenses)
  double get netBalance => totalIncome - totalExpenses;

  /// Get currency (default RWF, or selected wallet's currency)
  String get currency => _selectedWallet?.currency ?? 'RWF';

  /// Get wallet name by ID
  String? getWalletName(String walletId) {
    try {
      return _wallets.firstWhere((w) => w.id == walletId).name;
    } catch (e) {
      return null;
    }
  }

  /// Initialize home screen data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadWallets();
      await _loadRecentTransactions();
    } catch (e) {
      debugPrint('Error initializing home screen: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load wallets from repository
  Future<void> _loadWallets() async {
    _wallets = _walletRepository.getActiveWallets();
  }

  /// Load recent transactions
  Future<void> _loadRecentTransactions() async {
    if (_selectedWallet != null) {
      _recentTransactions = _transactionRepository
          .getTransactionsByWallet(_selectedWallet!.id)
          .take(10)
          .toList();
    } else {
      _recentTransactions = _transactionRepository.getRecentTransactions(limit: 10);
    }
  }

  /// Select a wallet (null for all wallets)
  Future<void> selectWallet(Wallet? wallet) async {
    _selectedWallet = wallet;
    await _loadRecentTransactions();
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  /// Get transactions grouped by date
  Map<String, List<Transaction>> get groupedTransactions {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in _recentTransactions) {
      final dateKey = _formatDateKey(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
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

  /// Get formatted balance string
  String getFormattedBalance() {
    return '$currency ${_formatNumber(totalBalance)}';
  }

  /// Get formatted income string
  String getFormattedIncome() {
    return '$currency ${_formatNumber(totalIncome)}';
  }

  /// Get formatted expenses string
  String getFormattedExpenses() {
    return '$currency ${_formatNumber(totalExpenses)}';
  }

  /// Format number with commas
  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
