/// App-wide constants for Vinsla AI Academy
class AppConstants {
  AppConstants._();

  static const String appName     = 'Vinsla AI Academy';
  static const String tagline     = 'Learn AI the Smart Way';
  static const String appVersion  = '1.0.0';

  // API
  static const String baseUrl         = 'http://localhost:5000/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Storage keys
  static const String kAccessToken  = 'access_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUserId       = 'user_id';
  static const String kThemeMode    = 'theme_mode';
  static const String kOnboarded    = 'onboarded';

  // Course categories
  static const String catPython = 'python';
  static const String catAI     = 'ai';
  static const String catML     = 'ml';

  // Pagination
  static const int defaultPageSize = 20;

  // Quiz
  static const int minPassScore = 70;
}
