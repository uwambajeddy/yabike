/// Spacing constants following the 4px base unit system
class AppSpacing {
  AppSpacing._();

  // Base unit: 4px
  static const double baseUnit = 4.0;

  // Spacing scale
  static const double xs = 4.0; // 1x base unit
  static const double sm = 8.0; // 2x base unit
  static const double md = 12.0; // 3x base unit
  static const double lg = 16.0; // 4x base unit
  static const double xl = 24.0; // 6x base unit
  static const double xxl = 32.0; // 8x base unit
  static const double xxxl = 48.0; // 12x base unit

  // Common usage aliases
  static const double paddingSmall = sm;
  static const double paddingMedium = lg;
  static const double paddingLarge = xl;

  static const double marginSmall = sm;
  static const double marginMedium = lg;
  static const double marginLarge = xl;

  static const double gapSmall = sm;
  static const double gapMedium = md;
  static const double gapLarge = lg;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircle = 999.0;

  // Card and container spacing
  static const double cardPadding = lg; // 16px
  static const double cardMargin = lg; // 16px
  static const double cardRadius = radiusLarge; // 16px

  // List item spacing
  static const double listItemPadding = lg; // 16px
  static const double listItemSpacing = sm; // 8px

  // Screen padding
  static const double screenPaddingHorizontal = lg; // 16px
  static const double screenPaddingVertical = lg; // 16px

  // Section spacing
  static const double sectionSpacing = xl; // 24px
  static const double componentSpacing = lg; // 16px

  /// Helper method to get spacing multiple
  static double multiple(double multiplier) {
    return baseUnit * multiplier;
  }
}
