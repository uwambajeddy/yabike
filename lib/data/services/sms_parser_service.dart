import '../models/transaction_model.dart';

/// Service for parsing SMS messages into transactions
class SmsParserService {
  /// Parse Equity Bank SMS message
  static Transaction? parseEquityBankSMS(Map<String, dynamic> smsData) {
    final String rawMessage = smsData['rawMessage'] as String;
    final String id = smsData['id'] as String;
    final DateTime date = DateTime.parse(smsData['date'] as String);

    try {
      // Pattern: "{amount} {currency} was successfully sent to {recipient} {phone}. MTN Ref. {ref}. Ref. {ref} on {date} at {time} CAT. Charges {charge} USD"
      // Or: "{amount} {currency} has been successfully sent to {recipient} {account}. Ref. {ref} on {date} at {time} CAT. Transaction charge {charge} USD, SMS alert charge {smsCharge} USD"
      // Or: "You have received {amount} {currency} from {sender} {account} to your Equity account {yourAccount}. Ref. {ref} on {date} at {time} CAT"

      final RegExp sentPattern = RegExp(
        r'(\d+\.?\d*)\s+(RWF|USD)\s+(?:was successfully sent|has been successfully sent)\s+to\s+(.+?)\s+(\d{10,}|4\*+\d+).*?Ref\.\s+([A-Z0-9]+).*?(?:Charges?|Transaction charge)\s+(\d+\.?\d*)\s+USD',
        caseSensitive: false,
      );

      final RegExp receivedPattern = RegExp(
        r'You have received\s+(\d+\.?\d*)\s+(RWF|USD)\s+from\s+(.+?)\s+(4\*+\d+).*?Equity account\s+(4\*+\d+).*?Ref\.\s+([A-Z0-9]+)',
        caseSensitive: false,
      );

      // Try sent pattern
      final sentMatch = sentPattern.firstMatch(rawMessage);
      if (sentMatch != null) {
        final amount = double.parse(sentMatch.group(1)!);
        final currency = sentMatch.group(2)!;
        final recipient = sentMatch.group(3)!.trim();
        final recipientPhone = sentMatch.group(4)!;
        final reference = sentMatch.group(5)!;
        final charge = double.parse(sentMatch.group(6)!);

        return Transaction(
          id: id,
          date: date,
          source: 'EQUITYBANK',
          rawMessage: rawMessage,
          type: 'debit',
          category: 'Transfer',
          amount: amount,
          currency: currency,
          amountRWF: currency == 'USD' ? amount * 1300 : amount, // Rough conversion
          fee: charge,
          reference: reference,
          recipient: recipient,
          recipientPhone: recipientPhone.replaceAll('*', ''),
          description: 'Sent to $recipient',
        );
      }

      // Try received pattern
      final receivedMatch = receivedPattern.firstMatch(rawMessage);
      if (receivedMatch != null) {
        final amount = double.parse(receivedMatch.group(1)!);
        final currency = receivedMatch.group(2)!;
        final sender = receivedMatch.group(3)!.trim();
        // final senderAccount = receivedMatch.group(4)!;
        final reference = receivedMatch.group(6)!;

        return Transaction(
          id: id,
          date: date,
          source: 'EQUITYBANK',
          rawMessage: rawMessage,
          type: 'credit',
          category: 'Transfer',
          amount: amount,
          currency: currency,
          amountRWF: currency == 'USD' ? amount * 1300 : amount,
          reference: reference,
          sender: sender,
          description: 'Received from $sender',
        );
      }

      return null;
    } catch (e) {
      print('Error parsing Equity Bank SMS: $e');
      return null;
    }
  }

  /// Parse MTN MoMo SMS message
  static Transaction? parseMTNMoMoSMS(Map<String, dynamic> smsData) {
    final String rawMessage = smsData['rawMessage'] as String;
    final String id = smsData['id'] as String;
    final DateTime date = DateTime.parse(smsData['date'] as String);

    try {
      // Pattern for sent: "You have sent {amount} Rwf to {recipient} {phone}. New balance is {balance} Rwf. Transaction ID: {ref}. Fee {fee} Rwf."
      // Pattern for received: "You have received {amount} Rwf from {sender} {phone}. New balance is {balance} Rwf. Transaction ID: {ref}."
      // Pattern for airtime: "You have bought {amount} Rwf airtime for {phone}. New balance is {balance} Rwf. Transaction ID: {ref}. Fee {fee} Rwf."

      final RegExp sentPattern = RegExp(
        r'You have sent\s+(\d+\.?\d*)\s+Rwf\s+to\s+(.+?)\s+(\d{10}).*?New balance is\s+(\d+\.?\d*)\s+Rwf.*?Transaction ID:\s+([A-Z0-9]+)\.?\s*(?:Fee\s+(\d+\.?\d*)\s+Rwf)?',
        caseSensitive: false,
      );

      final RegExp receivedPattern = RegExp(
        r'You have received\s+(\d+\.?\d*)\s+Rwf\s+from\s+(.+?)\s+(\d{10}).*?New balance is\s+(\d+\.?\d*)\s+Rwf.*?Transaction ID:\s+([A-Z0-9]+)',
        caseSensitive: false,
      );

      final RegExp airtimePattern = RegExp(
        r'You have bought\s+(\d+\.?\d*)\s+Rwf\s+airtime\s+for\s+(\d{10}).*?New balance is\s+(\d+\.?\d*)\s+Rwf.*?Transaction ID:\s+([A-Z0-9]+)\.?\s*(?:Fee\s+(\d+\.?\d*)\s+Rwf)?',
        caseSensitive: false,
      );

      // Try sent pattern
      final sentMatch = sentPattern.firstMatch(rawMessage);
      if (sentMatch != null) {
        final amount = double.parse(sentMatch.group(1)!);
        final recipient = sentMatch.group(2)!.trim();
        final recipientPhone = sentMatch.group(3)!;
        final balance = double.parse(sentMatch.group(4)!);
        final reference = sentMatch.group(5)!;
        final fee = sentMatch.group(6) != null ? double.parse(sentMatch.group(6)!) : 0.0;

        return Transaction(
          id: id,
          date: date,
          source: 'MTNMOMO',
          rawMessage: rawMessage,
          type: 'debit',
          category: 'Transfer',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          fee: fee,
          balanceRWF: balance,
          reference: reference,
          recipient: recipient,
          recipientPhone: recipientPhone,
          description: 'Sent to $recipient',
        );
      }

      // Try received pattern
      final receivedMatch = receivedPattern.firstMatch(rawMessage);
      if (receivedMatch != null) {
        final amount = double.parse(receivedMatch.group(1)!);
        final sender = receivedMatch.group(2)!.trim();
        // final senderPhone = receivedMatch.group(3)!;
        final balance = double.parse(receivedMatch.group(4)!);
        final reference = receivedMatch.group(5)!;

        return Transaction(
          id: id,
          date: date,
          source: 'MTNMOMO',
          rawMessage: rawMessage,
          type: 'credit',
          category: 'Transfer',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          balanceRWF: balance,
          reference: reference,
          sender: sender,
          description: 'Received from $sender',
        );
      }

      // Try airtime pattern
      final airtimeMatch = airtimePattern.firstMatch(rawMessage);
      if (airtimeMatch != null) {
        final amount = double.parse(airtimeMatch.group(1)!);
        final phone = airtimeMatch.group(2)!;
        final balance = double.parse(airtimeMatch.group(3)!);
        final reference = airtimeMatch.group(4)!;
        final fee = airtimeMatch.group(5) != null ? double.parse(airtimeMatch.group(5)!) : 0.0;

        return Transaction(
          id: id,
          date: date,
          source: 'MTNMOMO',
          rawMessage: rawMessage,
          type: 'debit',
          category: 'Airtime',
          amount: amount,
          currency: 'RWF',
          amountRWF: amount,
          fee: fee,
          balanceRWF: balance,
          reference: reference,
          recipientPhone: phone,
          description: 'Airtime purchase',
        );
      }

      return null;
    } catch (e) {
      print('Error parsing MTN MoMo SMS: $e');
      return null;
    }
  }

  /// Parse SMS based on source
  static Transaction? parseSMS(Map<String, dynamic> smsData) {
    final String source = smsData['source'] as String;

    switch (source.toUpperCase()) {
      case 'EQUITYBANK':
        return parseEquityBankSMS(smsData);
      case 'MTNMOMO':
      case 'MTN':
        return parseMTNMoMoSMS(smsData);
      default:
        return null;
    }
  }

  /// Parse multiple SMS messages
  static List<Transaction> parseBulkSMS(List<Map<String, dynamic>> smsList) {
    final List<Transaction> transactions = [];

    for (final sms in smsList) {
      final transaction = parseSMS(sms);
      if (transaction != null) {
        transactions.add(transaction);
      }
    }

    return transactions;
  }
}
