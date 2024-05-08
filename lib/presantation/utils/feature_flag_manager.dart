import 'dart:async';

import 'package:flutter/foundation.dart';

class FeatureFlagManager {
  static final FeatureFlagManager _instance = FeatureFlagManager._internal();

  factory FeatureFlagManager() {
    return _instance;
  }

  FeatureFlagManager._internal();

  Map<String, bool> _featureFlags = {};

  Future<void> initialize() async {
    // Simulate fetching feature flags from a remote server or database
    await Future.delayed(const Duration(seconds: 1));
    _featureFlags = await _fetchFeatureFlags();
  }

  Future<Map<String, bool>> _fetchFeatureFlags() async {
    // In a real-world scenario, this method would make an HTTP request to fetch
    // feature flags from a remote server or query a database.
    return {
      'new_feature_enabled': true,
      'experimental_feature_enabled': false,
      'dark_mode_enabled': true,
    };
  }

  bool isFeatureEnabled(String featureName) {
    return _featureFlags.containsKey(featureName) && _featureFlags[featureName]!;
  }
}

void main() async {
  final featureFlagManager = FeatureFlagManager();
  await featureFlagManager.initialize();

  // Example usage
  if (featureFlagManager.isFeatureEnabled('new_feature_enabled')) {
    if (kDebugMode) {
      print('New feature is enabled!');
    }
  } else {
    if (kDebugMode) {
      print('New feature is disabled.');
    }
  }
}
