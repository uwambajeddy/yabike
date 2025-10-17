import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository = TransactionRepository();

  bool _isLoading = false;
  Transaction? _transaction;
  String _emoji = '💰';
  String _note = '';

  bool get isLoading => _isLoading;
  Transaction? get transaction => _transaction;
  String get emoji => _emoji;
  String get note => _note;

  Future<void> initialize(Transaction transaction) async {
    _isLoading = true;
    _transaction = transaction;
    notifyListeners();

    try {
      // Load emoji from storage if exists
      _emoji = await _loadEmoji(transaction.id);
      
      // Extract note from raw message or description
      _note = _extractNote(transaction);
    } catch (e) {
      debugPrint('Error initializing transaction detail: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _loadEmoji(String transactionId) async {
    // TODO: Load from storage
    // For now, return default based on category
    return _getDefaultEmoji(_transaction?.category ?? '');
  }

  String _getDefaultEmoji(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('food') || categoryLower.contains('restaurant')) return '🍔';
    if (categoryLower.contains('transport') || categoryLower.contains('vehicle')) return '🚗';
    if (categoryLower.contains('shopping') || categoryLower.contains('retail')) return '🛍️';
    if (categoryLower.contains('entertainment')) return '🎬';
    if (categoryLower.contains('health') || categoryLower.contains('medical')) return '💊';
    if (categoryLower.contains('investment') || categoryLower.contains('dividend')) return '💰';
    if (categoryLower.contains('salary') || categoryLower.contains('income')) return '💵';
    if (categoryLower.contains('transfer')) return '💸';
    if (categoryLower.contains('bill') || categoryLower.contains('utility')) return '📄';
    return '💰'; // Default
  }

  String _extractNote(Transaction transaction) {
    // Try to extract meaningful note from raw message
    // For manually added transactions, this might be stored separately
    // For SMS transactions, we can parse the raw message
    return '';
  }

  Future<bool> deleteTransaction() async {
    if (_transaction == null) return false;

    try {
      // Delete transaction using repository
      await _transactionRepository.deleteTransaction(_transaction!.id);
      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }
}
