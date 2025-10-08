import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet_model.dart';

/// Repository for wallet data access
class WalletRepository {
  static const String _walletsBoxName = 'wallets';
  
  /// Get the wallets box
  Box get _walletsBox => Hive.box(_walletsBoxName);
  
  /// Initialize the wallets box (not needed - opened in main.dart)
  static Future<void> init() async {
    // Box is already opened in main.dart
  }
  
  /// Get all wallets
  List<Wallet> getAllWallets() {
    return _walletsBox.values
        .map((e) => Wallet.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
  
  /// Get active wallets only
  List<Wallet> getActiveWallets() {
    return getAllWallets().where((wallet) => wallet.isActive).toList();
  }
  
  /// Get wallet by ID
  Wallet? getWalletById(String id) {
    return _walletsBox.values.firstWhere(
      (wallet) => wallet.id == id,
      orElse: () => throw Exception('Wallet not found'),
    );
  }
  
  /// Add a new wallet
  Future<void> addWallet(Wallet wallet) async {
    await _walletsBox.put(wallet.id, wallet.toJson());
  }
  
  /// Add multiple wallets (for SMS import)
  Future<void> addWallets(List<Wallet> wallets) async {
    final Map<String, dynamic> walletsMap = {
      for (var wallet in wallets) wallet.id: wallet.toJson()
    };
    await _walletsBox.putAll(walletsMap);
  }
  
  /// Update wallet
  Future<void> updateWallet(Wallet wallet) async {
    await _walletsBox.put(wallet.id, wallet.toJson());
  }
  
  /// Delete wallet
  Future<void> deleteWallet(String id) async {
    await _walletsBox.delete(id);
  }
  
  /// Update wallet balance
  Future<void> updateWalletBalance(String walletId, double newBalance) async {
    final wallet = getWalletById(walletId);
    if (wallet != null) {
      final updatedWallet = wallet.copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
      await updateWallet(updatedWallet);
    }
  }
  
  /// Get total balance across all active wallets
  double getTotalBalance() {
    return getActiveWallets().fold(0.0, (sum, wallet) => sum + wallet.balance);
  }
  
  /// Get total balance in specific currency
  double getTotalBalanceInCurrency(String currency) {
    return getActiveWallets()
        .where((wallet) => wallet.currency == currency)
        .fold(0.0, (sum, wallet) => sum + wallet.balance);
  }
  
  /// Check if any wallets exist
  bool hasWallets() {
    return _walletsBox.isNotEmpty;
  }
  
  /// Get wallets by type (bank, momo, cash)
  List<Wallet> getWalletsByType(String type) {
    return getActiveWallets().where((wallet) => wallet.type == type).toList();
  }
  
  /// Get wallets by provider
  List<Wallet> getWalletsByProvider(String provider) {
    return getActiveWallets()
        .where((wallet) => wallet.provider == provider)
        .toList();
  }
  
  /// Listen to wallet changes
  Stream<List<Wallet>> watchWallets() {
    return _walletsBox.watch().map((event) => getAllWallets());
  }
  
  /// Close the box
  Future<void> close() async {
    await _walletsBox.close();
  }
}
