class AppConstants {
  AppConstants._();

  // App Info
  static const String appVersion = '0.1.0';
  static const String packageName = 'com.projectmicah.app';

  // API Configuration
  static const String apiBaseUrl = 'https://api.projectmicah.com';
  static const int apiTimeout = 30000; // milliseconds

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserType = 'user_type';
  static const String keyThemeMode = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxUsernameLength = 50;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';

  // Animation Durations (milliseconds)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // Debounce Durations (milliseconds)
  static const int debounceDuration = 500;
  static const int searchDebounceDuration = 300;
}
