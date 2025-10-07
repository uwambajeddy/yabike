import 'package:uuid/uuid.dart';

/// Transaction data model
class Transaction {
  final String id;
  final DateTime date;
  final String source;
  final String rawMessage;
  final String type; // 'credit' or 'debit'
  final String category;
  final double amount;
  final String currency;
  final double amountRWF;
  final double? fee;
  final double? balanceRWF;
  final String? reference;
  final String? recipient;
  final String? recipientPhone;
  final String? sender;
  final String description;
  final String? walletId;

  Transaction({
    String? id,
    required this.date,
    required this.source,
    required this.rawMessage,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    required this.amountRWF,
    this.fee,
    this.balanceRWF,
    this.reference,
    this.recipient,
    this.recipientPhone,
    this.sender,
    required this.description,
    this.walletId,
  }) : id = id ?? const Uuid().v4();

  // From JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      source: json['source'] as String,
      rawMessage: json['rawMessage'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      amountRWF: (json['amountRWF'] as num).toDouble(),
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
      balanceRWF: json['balanceRWF'] != null
          ? (json['balanceRWF'] as num).toDouble()
          : null,
      reference: json['reference'] as String?,
      recipient: json['recipient'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
      sender: json['sender'] as String?,
      description: json['description'] as String,
      walletId: json['walletId'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'source': source,
      'rawMessage': rawMessage,
      'type': type,
      'category': category,
      'amount': amount,
      'currency': currency,
      'amountRWF': amountRWF,
      'fee': fee,
      'balanceRWF': balanceRWF,
      'reference': reference,
      'recipient': recipient,
      'recipientPhone': recipientPhone,
      'sender': sender,
      'description': description,
      'walletId': walletId,
    };
  }

  // Copy with
  Transaction copyWith({
    String? id,
    DateTime? date,
    String? source,
    String? rawMessage,
    String? type,
    String? category,
    double? amount,
    String? currency,
    double? amountRWF,
    double? fee,
    double? balanceRWF,
    String? reference,
    String? recipient,
    String? recipientPhone,
    String? sender,
    String? description,
    String? walletId,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      source: source ?? this.source,
      rawMessage: rawMessage ?? this.rawMessage,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountRWF: amountRWF ?? this.amountRWF,
      fee: fee ?? this.fee,
      balanceRWF: balanceRWF ?? this.balanceRWF,
      reference: reference ?? this.reference,
      recipient: recipient ?? this.recipient,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      sender: sender ?? this.sender,
      description: description ?? this.description,
      walletId: walletId ?? this.walletId,
    );
  }

  // Check if transaction is income
  bool get isIncome => type == 'credit';

  // Check if transaction is expense
  bool get isExpense => type == 'debit';
}
