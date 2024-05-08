import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
 final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Singleton pattern: Private constructor and static instance variable
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Set user id for tracking
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Log custom event with parameters
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  // Log page view
  Future<void> logPageView(String name) async {
    await _analytics.logScreenView(screenName: name);
  }

  // Get observer for integration with Navigator
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
}


