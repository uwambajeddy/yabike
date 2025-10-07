import 'package:intl/intl.dart';

/// Data formatters for consistent display
class Formatters {
  Formatters._();

  /// Format currency amount
  static String currency(double amount, {String currency = 'RWF'}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return '${formatter.format(amount)} $currency';
  }

  /// Format currency amount with symbol
  static String currencyWithSymbol(double amount, {String currency = 'RWF'}) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  /// Get currency symbol
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'RWF':
        return 'FRw';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  /// Format date
  static String date(DateTime dateTime, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Format time
  static String time(DateTime dateTime, {String format = 'HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Format date and time
  static String dateTime(DateTime dateTime,
      {String format = 'dd MMM yyyy, HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Format relative time (e.g., "2 hours ago")
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  /// Format phone number
  static String phoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Format as: +250 78X XXX XXX
    if (digitsOnly.startsWith('250') && digitsOnly.length == 12) {
      return '+${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 9)} ${digitsOnly.substring(9)}';
    } else if (digitsOnly.startsWith('07') && digitsOnly.length == 10) {
      return '+250 ${digitsOnly.substring(1, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
    }
    return phone;
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format compact number (e.g., 1.5K, 2.3M)
  static String compactNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  /// Format account number (mask middle digits)
  static String accountNumber(String account) {
    if (account.length <= 4) return account;
    final visible = 4;
    final masked = '*' * (account.length - visible);
    return masked + account.substring(account.length - visible);
  }
}
