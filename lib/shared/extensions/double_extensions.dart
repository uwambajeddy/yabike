extension DoubleExtensions on double {
  /// Format as currency
  String toCurrency({String currency = 'RWF'}) {
    final formatted = this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2);
    return '$formatted $currency';
  }

  /// Format as percentage
  String toPercentage({int decimals = 1}) {
    return '${toStringAsFixed(decimals)}%';
  }

  /// Clamp between min and max
  double clampDouble(double min, double max) {
    return clamp(min, max).toDouble();
  }
}
