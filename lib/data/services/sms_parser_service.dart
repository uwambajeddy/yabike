import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/transaction_model.dart';

class SmsParserService {
  // Constants (matching React Native implementation)
  static const double usdToRwf = 1440.0;
  
  /// Generate a unique transaction ID based on date and message content
  /// This prevents duplicate IDs when processing multiple SMS at once
  static String _generateTransactionId(DateTime date, String message) {
    // Use the date's milliseconds as base
    final dateId = date.millisecondsSinceEpoch.toString();
    
    // Create a short hash from the message to ensure uniqueness
    final messageHash = md5.convert(utf8.encode(message)).toString().substring(0, 6);
    
    return '$dateId$messageHash';
  }
  
  static const List<String> smsSenders = [
    'EQUITYBANK',
    'M-MONEY',
  ];
  
  static const List<String> excludePatterns = [
    'Never share this code',
    'One-Time-Pin',
    'OTM',
    'Use code',
    'Do no share',
    'Customer Care',
    'balance of accumulated interest',
  ];
  
  static const List<String> transactionIndicators = [
    'RWF',
    'USD',
    'transferred',
    'received',
    'sent',
    'withdrawn',
    'deposited',
    'payment',
    'completed',
    'successfully',
    'balance:',
    'new balance',
    'Fee',
    'TxId:',
    'Ref.',
    'Transaction Id',
  ];

  /// Filter to check if SMS is a transaction message
  static bool isTransactionMessage(String message, String? sender) {
    // Check if from known sender
    if (sender == null || !smsSenders.any((s) => sender.toUpperCase().contains(s))) {
      return false;
    }
    
    // Exclude OTP and verification messages
    for (final pattern in excludePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(message)) {
        return false;
      }
    }
    
    // Check if contains transaction indicators
    final hasIndicator = transactionIndicators.any(
      (indicator) => message.contains(indicator)
    );
    
    return hasIndicator;
  }

  static Transaction? parseSms(String message, String sender, DateTime date) {
    // Filter out non-transaction messages
    if (!isTransactionMessage(message, sender)) {
      debugPrint('Filtered out: Not a transaction message');
      return null;
    }
    
    if (sender.toUpperCase().contains('EQUITYBANK')) {
      return _parseEquityBankSMS(message, date);
    } else if (sender.toUpperCase().contains('M-MONEY')) {
      return _parseMTNMoMoSMS(message, date);
    }
    return null;
  }

  static Transaction? _parseEquityBankSMS(String message, DateTime date) {
    try {
      // Pattern 1: Money sent (transfer out)
      // Example: "10000.00 RWF was successfully sent to Eddy UWAMBAJE 250785850860"
      final sentMatch = RegExp(
        r'(\d+(?:\.\d+)?)\s+(RWF|USD)\s+(?:was|has been) successfully sent to\s+([^0-9]+)\s*([\d\*]+)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (sentMatch != null) {
        final amount = double.parse(sentMatch.group(1)!);
        final currency = sentMatch.group(2)!;
        final recipient = sentMatch.group(3)!.trim();
        final phone = sentMatch.group(4)!;
        
        // Convert USD to RWF
        final amountRWF = currency.toUpperCase() == 'USD' ? amount * usdToRwf : amount;
        
        // Extract reference
        final refMatch = RegExp(r'Ref\.\s+([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final reference = refMatch?.group(1);
        
        // Extract charges if any
        final chargesMatch = RegExp(r'charges?\s+(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(message);
        double? charges;
        if (chargesMatch != null) {
          charges = double.parse(chargesMatch.group(1)!);
          if (currency.toUpperCase() == 'USD') charges = charges * usdToRwf;
        }
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'EQUITYBANK',
          rawMessage: message,
          type: 'debit',
          category: 'Transfer',
          amount: amount,
          currency: currency,
          amountRWF: amountRWF,
          description: 'Sent to $recipient',
          recipient: '$recipient ($phone)',
          reference: reference,
          fee: charges,
        );
      }

      // Pattern 2: Money received (transfer in)
      // Example: "You have received 1388.00 RWF from ABDOUL LATIF MUGISHA 4********3578"
      final receivedMatch = RegExp(
        r'You have received\s+(\d+(?:\.\d+)?)\s+(RWF|USD)\s+from\s+([^0-9]+)\s*([\d\*]+)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (receivedMatch != null) {
        final amount = double.parse(receivedMatch.group(1)!);
        final currency = receivedMatch.group(2)!;
        final sender = receivedMatch.group(3)!.trim();
        
        final amountRWF = currency.toUpperCase() == 'USD' ? amount * usdToRwf : amount;
        
        final refMatch = RegExp(r'ref\s+([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final reference = refMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'EQUITYBANK',
          rawMessage: message,
          type: 'credit',
          category: 'Transfer',
          amount: amount,
          currency: currency,
          amountRWF: amountRWF,
          description: 'Received from $sender',
          recipient: sender,
          reference: reference,
        );
      }

      // Pattern 3: ATM/Agent withdrawal
      // Example: "Dear UWAMBAJE, you have withdrawn USD 400 withdraw charges 5.01 ref 5047944 from REMERA"
      final withdrawnMatch = RegExp(
        r'withdrawn\s+(USD|RWF)\s+(\d+(?:\.\d+)?)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (withdrawnMatch != null) {
        final currency = withdrawnMatch.group(1)!;
        final amount = double.parse(withdrawnMatch.group(2)!);
        
        final amountRWF = currency.toUpperCase() == 'USD' ? amount * usdToRwf : amount;
        
        // Extract charges
        final chargesMatch = RegExp(r'charges?\s+(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(message);
        double? charges;
        if (chargesMatch != null) {
          charges = double.parse(chargesMatch.group(1)!);
          if (currency.toUpperCase() == 'USD') charges = charges * usdToRwf;
        }
        
        final refMatch = RegExp(r'ref\s+([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final reference = refMatch?.group(1);
        
        // Extract location
        final locationMatch = RegExp(r'from\s+([A-Z\s]+)', caseSensitive: false).firstMatch(message);
        final location = locationMatch?.group(1)?.trim();
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'EQUITYBANK',
          rawMessage: message,
          type: 'debit',
          category: 'Cash Withdrawal',
          amount: amount,
          currency: currency,
          amountRWF: amountRWF,
          description: location != null ? 'Withdrawn at $location' : 'Cash withdrawal',
          reference: reference,
          fee: charges,
        );
      }

      // Pattern 4: Deposit
      // Example: "Dear UWAMBAJE,You have deposited USD 12 Deposit charges 0 ref 5044545 from REMERA"
      final depositedMatch = RegExp(
        r'deposited\s+(USD|RWF)\s+(\d+(?:\.\d+)?)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (depositedMatch != null) {
        final currency = depositedMatch.group(1)!;
        final amount = double.parse(depositedMatch.group(2)!);
        
        final amountRWF = currency.toUpperCase() == 'USD' ? amount * usdToRwf : amount;
        
        final chargesMatch = RegExp(r'charges?\s+(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(message);
        double? charges;
        if (chargesMatch != null) {
          charges = double.parse(chargesMatch.group(1)!);
          if (currency.toUpperCase() == 'USD') charges = charges * usdToRwf;
        }
        
        final refMatch = RegExp(r'ref\s+([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final reference = refMatch?.group(1);
        
        final locationMatch = RegExp(r'from\s+([A-Z\s]+)', caseSensitive: false).firstMatch(message);
        final location = locationMatch?.group(1)?.trim();
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'EQUITYBANK',
          rawMessage: message,
          type: 'credit',
          category: 'Deposit',
          amount: amount,
          currency: currency,
          amountRWF: amountRWF,
          description: location != null ? 'Deposited at $location' : 'Cash deposit',
          reference: reference,
          fee: charges,
        );
      }

      // Pattern 5: Card authorization
      // Example: "Dear UWAMBAJE, Auth for card 4576..8017 Date:2024-12-14 00:10:33 Amt: USD 20.00 Details:VERCEL INC."
      final cardAuthMatch = RegExp(
        r'Auth for card.*?Amt:\s+(USD|RWF)\s+(\d+(?:\.\d+)?)\s+Details:\s*(.+)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (cardAuthMatch != null) {
        final currency = cardAuthMatch.group(1)!;
        final amount = double.parse(cardAuthMatch.group(2)!);
        final merchant = cardAuthMatch.group(3)!.split('.').first.trim();
        
        final amountRWF = currency.toUpperCase() == 'USD' ? amount * usdToRwf : amount;
        
        // Extract card number
        final cardMatch = RegExp(r'card\s+([\d\.]+)', caseSensitive: false).firstMatch(message);
        final cardNumber = cardMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'EQUITYBANK',
          rawMessage: message,
          type: 'debit',
          category: 'Card Payment',
          amount: amount,
          currency: currency,
          amountRWF: amountRWF,
          description: 'Card payment to $merchant',
          recipient: merchant,
          reference: cardNumber,
        );
      }

      // Pattern 6: Card debit
      // Example: "Dear UWAMBAJE, Debit for card 4576..8017 Date:2024-07-24 10:54:29 Amt: USD 0.00 Details:Card Product"
      final cardDebitMatch = RegExp(
        r'Debit for card.*?Amt:\s+(USD|RWF)\s+(\d+(?:\.\d+)?)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (cardDebitMatch != null) {
        final currency = cardDebitMatch.group(1)!;
        final amount = double.parse(cardDebitMatch.group(2)!);
        
        // Skip zero amount transactions
        if (amount == 0) return null;
        
        final amountRWF = currency.toUpperCase() == 'USD' ? amount * usdToRwf : amount;
        
        final detailsMatch = RegExp(r'Details:\s*(.+)', caseSensitive: false).firstMatch(message);
        final details = detailsMatch?.group(1)?.trim() ?? 'Card transaction';
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'EQUITYBANK',
          rawMessage: message,
          type: 'debit',
          category: 'Card Payment',
          amount: amount,
          currency: currency,
          amountRWF: amountRWF,
          description: details,
        );
      }

      // Pattern 7: Credit notification
      // Example: "Dear UWAMBAJE,You have been credited with USD 2457 ref 5044535 On: 05-Dec-24"
      final creditedMatch = RegExp(
        r'credited with\s+(USD|RWF)\s+(\d+(?:\.\d+)?)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (creditedMatch != null) {
        final currency = creditedMatch.group(1)!;
        final amount = double.parse(creditedMatch.group(2)!);
        
        final amountRWF = currency.toUpperCase() == 'USD' ? amount * usdToRwf : amount;
        
        final refMatch = RegExp(r'ref\s+([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final reference = refMatch?.group(1);
        
        final balanceMatch = RegExp(r'balance\s+(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!) : null;
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'EQUITYBANK',
          rawMessage: message,
          type: 'credit',
          category: 'Credit',
          amount: amount,
          currency: currency,
          amountRWF: amountRWF,
          description: 'Account credited',
          reference: reference,
          balanceRWF: balance,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error parsing Equity Bank SMS: $e');
      return null;
    }
  }

  static Transaction? _parseMTNMoMoSMS(String message, DateTime date) {
    try {
      // Pattern 1a: Money sent with *165*S* format
      // Example: "*165*S*400 RWF transferred to Jean Claude Sizeni (250782016311) from 22994074 at 2023-07-01 16:03:31 .Fee was:1500 RWF. New balance: 134500 RWF."
      final sentShortCodeMatch = RegExp(
        r'\*165\*S?\*(\d+)\s+RWF\s+transferred\s+to\s+([^(]+)\((\d+)\)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (sentShortCodeMatch != null) {
        final amountStr = sentShortCodeMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        final recipient = sentShortCodeMatch.group(2)!.trim();
        final phone = sentShortCodeMatch.group(3)!;
        
        // Extract fee
        final feeMatch = RegExp(r'Fee was:\s*([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final fee = feeMatch != null ? double.parse(feeMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract new balance
        final balanceMatch = RegExp(r'New balance:\s*([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract transaction reference from the "from XXXXX" part
        final fromMatch = RegExp(r'from\s+(\d+)', caseSensitive: false).firstMatch(message);
        final txId = fromMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'debit',
          category: 'Transfer',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Sent to $recipient',
          recipient: '$recipient ($phone)',
          reference: txId,
          fee: fee,
          balanceRWF: balance,
        );
      }

      // Pattern 1b: Money sent (transfer out)
      // Example: "You have transferred 5000 RWF to Eddy UWAMBAJE(250785850860)"
      final sentMatch = RegExp(
        r'(?:transferred|sent)\s+([\d,]+)\s+RWF\s+to\s+([^(]+)\((\*+)?(\d+)\)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (sentMatch != null) {
        final amountStr = sentMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        final recipient = sentMatch.group(2)!.trim();
        final phone = sentMatch.group(4)!;
        
        // Extract fee
        final feeMatch = RegExp(r'Fee (?:was|is):\s+([\d,]+)', caseSensitive: false).firstMatch(message);
        final fee = feeMatch != null ? double.parse(feeMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract new balance
        final balanceMatch = RegExp(r'New balance:\s+([\d,]+)', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract transaction ID
        final txIdMatch = RegExp(r'(?:TxId|Transaction Id):\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final txId = txIdMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'debit',
          category: 'Transfer',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Sent to $recipient',
          recipient: '$recipient ($phone)',
          reference: txId,
          fee: fee,
          balanceRWF: balance,
        );
      }

      // Pattern 2a: Money received with *162* or *165* format
      // Example: "*162*R*5000 RWF received from John Doe (250788123456) at 2023-07-01 16:03:31. New balance: 140000 RWF."
      final receivedShortCodeMatch = RegExp(
        r'\*16[25]\*[RS]?\*(\d+)\s+RWF\s+received\s+from\s+([^(]+)\((\d+)\)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (receivedShortCodeMatch != null) {
        final amountStr = receivedShortCodeMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        final sender = receivedShortCodeMatch.group(2)!.trim();
        final phone = receivedShortCodeMatch.group(3)!;
        
        // Extract new balance
        final balanceMatch = RegExp(r'New balance:\s*([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract transaction reference
        final fromMatch = RegExp(r'from\s+\d+\s+at.*?\.?(?:Ref|TxId)?:?\s*(\w+)', caseSensitive: false).firstMatch(message);
        final txId = fromMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'credit',
          category: 'Transfer',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Received from $sender',
          recipient: '$sender ($phone)',
          reference: txId,
          balanceRWF: balance,
        );
      }

      // Pattern 2b: Money received
      // Example: "You have received 10000 RWF from John DOE(***1234)"
      final receivedMatch = RegExp(
        r'You have received\s+([\d,]+)\s+RWF\s+from\s+([^(]+)\((\*+)?(\d+)\)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (receivedMatch != null) {
        final amountStr = receivedMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        final sender = receivedMatch.group(2)!.trim();
        
        final balanceMatch = RegExp(r'New balance:\s+([\d,]+)', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        final txIdMatch = RegExp(r'(?:TxId|Transaction Id):\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final txId = txIdMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'credit',
          category: 'Transfer',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Received from $sender',
          recipient: sender,
          reference: txId,
          balanceRWF: balance,
        );
      }

      // Pattern 3: Payment (including electricity, airtime, etc.)
      // Example: "Your payment of 17,500 RWF to EQUITY BANK RWANDA with token has been completed"
      final paymentMatch = RegExp(
        r'Your payment of\s+([\d,]+)\s+RWF\s+to\s+([^.]+)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (paymentMatch != null) {
        final amountStr = paymentMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        final recipient = paymentMatch.group(2)!.trim();
        
        // Detect category
        String category = 'Payment';
        if (message.toLowerCase().contains('cash power') || 
            message.toLowerCase().contains('eucl') ||
            message.toLowerCase().contains('electricity')) {
          category = 'Electricity';
        } else if (message.toLowerCase().contains('airtime')) {
          category = 'Airtime';
        }
        
        final feeMatch = RegExp(r'Fee (?:was|is):\s+([\d,]+)', caseSensitive: false).firstMatch(message);
        final fee = feeMatch != null ? double.parse(feeMatch.group(1)!.replaceAll(',', '')) : null;
        
        final txIdMatch = RegExp(r'(?:TxId|Transaction Id):\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final txId = txIdMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'debit',
          category: category,
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Payment to $recipient',
          recipient: recipient,
          reference: txId,
          fee: fee,
        );
      }

      // Pattern 4: Merchant payment
      // Example: "A transaction of 15,000 RWF by MERCHANT NAME on your MOMO"
      final merchantMatch = RegExp(
        r'(?:transaction|payment) of\s+([\d,]+)\s+RWF\s+(?:by|to)\s+([^.]+?)\s+on your (?:MOMO|account)',
        caseSensitive: false
      ).firstMatch(message);
      
      if (merchantMatch != null) {
        final amountStr = merchantMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        final merchant = merchantMatch.group(2)!.trim();
        
        final txIdMatch = RegExp(r'(?:TxId|Transaction Id):\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final txId = txIdMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'debit',
          category: 'Merchant Payment',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Payment to $merchant',
          recipient: merchant,
          reference: txId,
        );
      }

      // Pattern 5: Agent withdrawal
      // Example: "You have withdrawn 20,000 RWF from your mobile money"
      final agentWithdrawMatch = RegExp(
        r'withdrawn\s+([\d,]+)\s+RWF\s+from your mobile money',
        caseSensitive: false
      ).firstMatch(message);
      
      if (agentWithdrawMatch != null) {
        final amountStr = agentWithdrawMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        
        final feeMatch = RegExp(r'Fee (?:was|is):\s+([\d,]+)', caseSensitive: false).firstMatch(message);
        final fee = feeMatch != null ? double.parse(feeMatch.group(1)!.replaceAll(',', '')) : null;
        
        final txIdMatch = RegExp(r'(?:TxId|Transaction Id):\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final txId = txIdMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'debit',
          category: 'Cash Withdrawal',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Agent withdrawal',
          reference: txId,
          fee: fee,
        );
      }

      // Pattern 6: Transaction reversal/refund
      // Example: "*143*S*Your transaction to XXX IMANIZABAYO (250793053479) with 5000 RWF has been reversed at 2024-11-11 15:17:21. Your new balance is 5093 RWF."
      final reversalMatch = RegExp(
        r'\*143\*S?\*Your transaction to\s+([^(]+)\((\d+)\)\s+with\s+([\d,]+)\s+RWF\s+has been reversed',
        caseSensitive: false
      ).firstMatch(message);
      
      if (reversalMatch != null) {
        final recipient = reversalMatch.group(1)!.trim();
        final phone = reversalMatch.group(2)!;
        final amountStr = reversalMatch.group(3)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        
        // Extract new balance
        final balanceMatch = RegExp(r'new balance is\s+([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract date if available
        final dateMatch = RegExp(r'at\s+([\d-]+\s+[\d:]+)', caseSensitive: false).firstMatch(message);
        final reversalDate = dateMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'credit',
          category: 'Refund',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Transaction reversed - $recipient',
          recipient: '$recipient ($phone)',
          reference: reversalDate,
          balanceRWF: balance,
        );
      }

      // Pattern 7: Shortened merchant payment format (without "on your MOMO account")
      // Example: "*164*S*Y'ello, A transaction of 100 RWF by MTN RWANDACELL LIMITED was completed at 2025-10-11 01:01:29. Balance:72760 RWF. Fee 0 RWF. FT Id: 23409949413.*RW#"
      final shortMerchantMatch = RegExp(
        r"\*164\*S?\*Y'ello,?\s+A transaction of\s+([\d,]+)\s+RWF\s+by\s+([^.]+?)\s+was completed",
        caseSensitive: false
      ).firstMatch(message);
      
      if (shortMerchantMatch != null) {
        final amountStr = shortMerchantMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        final merchant = shortMerchantMatch.group(2)!.trim();
        
        // Extract balance
        final balanceMatch = RegExp(r'Balance:\s*([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract transaction ID
        final txIdMatch = RegExp(r'(?:FT Id|Financial Transaction Id):\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final txId = txIdMatch?.group(1);
        
        // Extract fee
        final feeMatch = RegExp(r'Fee\s+([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final fee = feeMatch != null ? double.parse(feeMatch.group(1)!.replaceAll(',', '')) : null;
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'debit',
          category: 'Merchant Payment',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Payment to $merchant',
          recipient: merchant,
          reference: txId,
          fee: fee,
          balanceRWF: balance,
        );
      }

      // Pattern 8: Adjustment/Credit to account
      // Example: "An adjustment has been made and 500 RWF has been added to your mobile money account 20092065 at 2025-01-29 16:06:06"
      final adjustmentMatch = RegExp(
        r'adjustment has been made and\s+([\d,]+)\s+RWF\s+has been added',
        caseSensitive: false
      ).firstMatch(message);
      
      if (adjustmentMatch != null) {
        final amountStr = adjustmentMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        
        // Extract new balance
        final balanceMatch = RegExp(r'NEW BALANCE:\s*([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        // Extract transaction ID
        final txIdMatch = RegExp(r'Financial Transaction Id:\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(message);
        final txId = txIdMatch?.group(1);
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'credit',
          category: 'Adjustment',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Account adjustment',
          reference: txId,
          balanceRWF: balance,
        );
      }

      // Pattern 9: Refund from MTN
      // Example: "*165*R*Y'ello, MTN RWANDACELL LIMITED has successfully refunded 3000 RWF to your mobile money account at 2025-01-25 09:01:17"
      final refundMatch = RegExp(
        r'\*165\*R\*.*?refunded\s+([\d,]+)\s+RWF',
        caseSensitive: false
      ).firstMatch(message);
      
      if (refundMatch != null) {
        final amountStr = refundMatch.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        
        // Extract new balance
        final balanceMatch = RegExp(r'new balance:\s*([\d,]+)\s+RWF', caseSensitive: false).firstMatch(message);
        final balance = balanceMatch != null ? double.parse(balanceMatch.group(1)!.replaceAll(',', '')) : null;
        
        return Transaction(
          id: _generateTransactionId(date, message),
          date: date,
          source: 'M-MONEY',
          rawMessage: message,
          type: 'credit',
          category: 'Refund',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          description: 'Refund from MTN RWANDACELL',
          balanceRWF: balance,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error parsing MTN MoMo SMS: $e');
      return null;
    }
  }
}

