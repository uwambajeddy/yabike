import 'package:uuid/uuid.dart';

/// Supported wallet categories within the app.
enum WalletType {
  cash,
  bank,
  momo,
}

/// Wallet data model
class Wallet {
  final String id;
  final String name;
  final String type; // 'momo', 'bank', 'cash'
  final String? provider; // 'MTN', 'Airtel', 'EquityBank', etc.
  final String? accountNumber;
  final double balance;
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    String? id,
    required this.name,
    required this.type,
    this.provider,
    this.accountNumber,
    this.balance = 0.0,
    this.currency = 'RWF',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // From JSON
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      provider: json['provider'] as String?,
      accountNumber: json['accountNumber'] as String?,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'RWF',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'provider': provider,
      'accountNumber': accountNumber,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with
  Wallet copyWith({
    String? id,
    String? name,
    String? type,
    String? provider,
    String? accountNumber,
    double? balance,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
