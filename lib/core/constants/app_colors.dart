import 'package:flutter/material.dart';

/// App-wide color constants following the design system style guide
class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS (GREEN) ====================
  static const Color primary100 = Color(0xFFE8F5E9); // Lightest
  static const Color primary200 = Color(0xFFC8E6C9);
  static const Color primary300 = Color(0xFFA5D6A7);
  static const Color primary400 = Color(0xFF81C784);
  static const Color primary500 = Color(0xFF66BB6A); // Main brand color
  static const Color primary600 = Color(0xFF4CAF50);
  static const Color primary700 = Color(0xFF43A047);
  static const Color primary800 = Color(0xFF388E3C);
  static const Color primary900 = Color(0xFF2E7D32); // Darkest

  // Main primary color alias
  static const Color primary = primary500;
  static const Color primaryDark = primary700;
  static const Color primaryLight = primary300;

  // ==================== DANGER/ERROR COLORS (RED) ====================
  static const Color danger100 = Color(0xFFFFEBEE); // Lightest
  static const Color danger200 = Color(0xFFFFCDD2);
  static const Color danger300 = Color(0xFFEF9A9A);
  static const Color danger400 = Color(0xFFE57373);
  static const Color danger500 = Color(0xFFF44336); // Main error color
  static const Color danger600 = Color(0xFFE53935);
  static const Color danger700 = Color(0xFFD32F2F);
  static const Color danger800 = Color(0xFFC62828);
  static const Color danger900 = Color(0xFFB71C1C); // Darkest

  // Error color alias
  static const Color error = danger500;
  static const Color errorDark = danger700;
  static const Color errorLight = danger300;

  // ==================== GRAYSCALE - WHITE ====================
  static const Color whitePrimary = Color(0xFFFFFFFF);
  static const Color whiteSecondary = Color(0xFFFAFAFA);
  static const Color whiteTertiary = Color(0xFFF5F5F5);
  static const Color whiteQuarternary = Color(0xFFEEEEEE);

  // ==================== GRAYSCALE - GRAY ====================
  static const Color grayPrimary = Color(0xFFE0E0E0);
  static const Color graySecondary = Color(0xFFBDBDBD);
  static const Color grayTertiary = Color(0xFF9E9E9E);
  static const Color grayQuarternary = Color(0xFF757575);
  static const Color grayQuinary = Color(0xFF616161);
  static const Color graySenary = Color(0xFF424242);
  static const Color graySeptenary = Color(0xFF303030);

  // ==================== GRAYSCALE - BLACK ====================
  static const Color blackPrimary = Color(0xFF424242);
  static const Color blackSecondary = Color(0xFF303030);
  static const Color blackTertiary = Color(0xFF212121);
  static const Color blackQuarternary = Color(0xFF1C1C1C);
  static const Color blackQuinary = Color(0xFF000000);

  // ==================== OTHER COLORS ====================
  static const Color blue = Color(0xFF42A5F5); // Informational elements
  static const Color lightGreen = Color(0xFFC5E1A5); // Success states
  static const Color yellow = Color(0xFFFFEB3B); // Warnings/highlights
  static const Color softYellow = Color(0xFFFFD966); // Softer yellow for progress bars and UI accents

  // ==================== SEMANTIC COLOR ALIASES ====================
  
  // Background Colors
  static const Color background = whitePrimary;
  static const Color backgroundSecondary = whiteSecondary;
  static const Color backgroundTertiary = whiteTertiary;
  static const Color backgroundDark = blackTertiary;
  static const Color backgroundDarkSecondary = blackSecondary;
  
  // Surface Colors
  static const Color surface = whitePrimary;
  static const Color surfaceSecondary = whiteSecondary;
  static const Color surfaceDark = graySenary;
  static const Color surfaceDarkSecondary = graySeptenary;

  // Text Colors
  static const Color textPrimary = blackPrimary;
  static const Color textSecondary = grayQuarternary;
  static const Color textTertiary = grayTertiary;
  static const Color textHint = graySecondary;
  static const Color textWhite = whitePrimary;
  static const Color textDisabled = graySecondary;

  // Border Colors
  static const Color border = grayPrimary;
  static const Color borderSecondary = graySecondary;
  static const Color borderDark = graySenary;

  // Status Colors
  static const Color success = primary500;
  static const Color successLight = lightGreen;
  static const Color warning = yellow;
  static const Color info = blue;

  // Transaction Type Colors
  static const Color income = primary500;
  static const Color expense = danger500;

  // Budget Status Colors
  static const Color budgetGood = primary500;
  static const Color budgetWarning = softYellow;
  static const Color budgetCritical = danger500;

  // Wallet Type Colors
  static const Color walletMomo = yellow;
  static const Color walletBank = blue;
  static const Color walletCash = primary500;

  // Category Colors (Material Design inspired)
  static const Color categoryFood = danger500;
  static const Color categoryTransport = blue;
  static const Color categoryShopping = yellow;
  static const Color categoryEntertainment = danger300;
  static const Color categoryUtilities = primary500;
  static const Color categoryHealth = blue;
  static const Color categoryEducation = primary700;
  static const Color categoryOthers = graySecondary;

  // ==================== GRADIENT COLORS ====================
  static const List<Color> primaryGradient = [
    primary500,
    primary700,
  ];

  static const List<Color> successGradient = [
    primary300,
    primary600,
  ];

  static const List<Color> dangerGradient = [
    danger500,
    danger700,
  ];

  static const List<Color> infoGradient = [
    blue,
    Color(0xFF1E88E5),
  ];
}
