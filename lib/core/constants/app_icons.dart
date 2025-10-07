/// Icon size and style constants following the design system
class AppIcons {
  AppIcons._();

  // ==================== ICON SIZES ====================
  // Standard icon sizes following the design system
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;
  static const double iconSizeXXLarge = 48.0;

  // Common usage aliases
  static const double iconButton = iconSizeLarge; // 24px
  static const double iconNavigation = iconSizeLarge; // 24px
  static const double iconActionBar = iconSizeMedium; // 20px
  static const double iconListItem = iconSizeMedium; // 20px
  static const double iconAvatar = iconSizeXLarge; // 32px
  static const double iconFeature = iconSizeXXLarge; // 48px

  // ==================== ICON STYLE ====================
  // All icons should use outlined style (not filled)
  // Consistent stroke width across all icons
  
  // ==================== COMMON ICON NAMES ====================
  // Using Material Icons with outlined style
  
  // Navigation Icons
  static const String home = 'home_outlined';
  static const String wallet = 'account_balance_wallet_outlined';
  static const String chart = 'bar_chart';
  static const String settings = 'settings_outlined';
  static const String profile = 'person_outline';
  
  // Action Icons
  static const String add = 'add';
  static const String edit = 'edit_outlined';
  static const String delete = 'delete_outline';
  static const String search = 'search';
  static const String filter = 'filter_list';
  static const String more = 'more_vert';
  static const String share = 'share_outlined';
  
  // Navigation/Direction Icons
  static const String arrowRight = 'arrow_forward';
  static const String arrowLeft = 'arrow_back';
  static const String arrowDown = 'arrow_downward';
  static const String arrowUp = 'arrow_upward';
  static const String chevronRight = 'chevron_right';
  static const String chevronLeft = 'chevron_left';
  
  // Status Icons
  static const String check = 'check';
  static const String checkCircle = 'check_circle_outline';
  static const String close = 'close';
  static const String error = 'error_outline';
  static const String warning = 'warning_amber';
  static const String info = 'info_outline';
  
  // Data/Content Icons
  static const String calendar = 'calendar_today';
  static const String clock = 'access_time';
  static const String location = 'location_on_outlined';
  static const String attachment = 'attach_file';
  static const String image = 'image_outlined';
  static const String document = 'description_outlined';
  
  // Finance Icons
  static const String money = 'attach_money';
  static const String creditCard = 'credit_card';
  static const String receipt = 'receipt_long';
  static const String transaction = 'swap_horiz';
  static const String income = 'arrow_circle_down';
  static const String expense = 'arrow_circle_up';
  
  // Category Icons
  static const String food = 'restaurant_outlined';
  static const String transport = 'directions_car_outlined';
  static const String shopping = 'shopping_bag_outlined';
  static const String entertainment = 'movie_outlined';
  static const String utilities = 'flash_on_outlined';
  static const String health = 'local_hospital_outlined';
  static const String education = 'school_outlined';
  
  // Notification Icons
  static const String notifications = 'notifications_outlined';
  static const String notificationsActive = 'notifications_active_outlined';
  static const String notificationsOff = 'notifications_off_outlined';
  
  // Security Icons
  static const String lock = 'lock_outlined';
  static const String unlock = 'lock_open_outlined';
  static const String fingerprint = 'fingerprint';
  static const String visibility = 'visibility_outlined';
  static const String visibilityOff = 'visibility_off_outlined';
  
  // Communication Icons
  static const String email = 'email_outlined';
  static const String phone = 'phone_outlined';
  static const String message = 'message_outlined';
  
  // ==================== USAGE GUIDELINES ====================
  
  /// Returns the appropriate icon size for the given context
  static double getSizeForContext(String context) {
    switch (context) {
      case 'button':
        return iconButton;
      case 'navigation':
        return iconNavigation;
      case 'list':
        return iconListItem;
      case 'avatar':
        return iconAvatar;
      case 'feature':
        return iconFeature;
      default:
        return iconSizeMedium;
    }
  }
  
  /// Icon style guidelines:
  /// - Use outlined icons (not filled)
  /// - Maintain consistent stroke width
  /// - Icons should be recognizable at all sizes
  /// - Use semantic names for better code readability
  /// - Prefer Material Icons outlined variants
}
