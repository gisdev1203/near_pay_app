import 'dart:ui';

class Constants {
  static const String apiUrl = 'https://api.example.com';
  static const int defaultTimeout = 30;
  static const List<String> supportedLanguages = ['en', 'fr', 'es'];

  // Colors
  static const primaryColor = Color(0xFF6200EE);
  static const secondaryColor = Color(0xFF03DAC6);
  static const backgroundColor = Color(0xFFF5F5F5);

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signUpEndpoint = '/auth/signup';
  static const String profileEndpoint = '/user/profile';

  // Error Messages
  static const String networkErrorMessage = 'Network error occurred. Please try again later.';
  static const String invalidCredentialsMessage = 'Invalid username or password.';

  // Font Sizes
  static const double smallFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 20.0;

  // Image Paths
  static const String logoImagePath = 'assets/images/logo.png';
  static const String backgroundImagePath = 'assets/images/background.jpg';
}
