import '../config/app_config.dart';

/// Input validators for forms
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }
    return null;
  }

  /// Validate PIN
  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (value.length < AppConfig.minPinLength ||
        value.length > AppConfig.maxPinLength) {
      return 'PIN must be ${AppConfig.minPinLength}-${AppConfig.maxPinLength} digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }
    return null;
  }

  /// Validate amount
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Invalid amount';
    }
    if (numValue <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  /// Validate phone number
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Rwanda phone number format: 250XXXXXXXXX or 07XXXXXXXX
    if (!RegExp(r'^(250|07)\d{9}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Invalid phone number';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  /// Validate wallet name
  static String? walletName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wallet name is required';
    }
    if (value.length < 2) {
      return 'Wallet name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Wallet name must be less than 50 characters';
    }
    return null;
  }

  /// Validate budget name
  static String? budgetName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget name is required';
    }
    if (value.length < 2) {
      return 'Budget name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Budget name must be less than 50 characters';
    }
    return null;
  }
}
