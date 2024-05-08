import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late SharedPreferences _prefs;

  PreferencesService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Methods for storing and retrieving primitive data types

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Advanced methods for storing and retrieving complex data types

  Future<void> setObject<T>(String key, T object) async {
    final String jsonString = object.toString();
    await _prefs.setString(key, jsonString);
  }

  T? getObject<T>(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString != null) {
      final T? object = _parseJsonToObject<T>(jsonString);
      return object;
    }
    return null;
  }

  T? _parseJsonToObject<T>(String jsonString) {
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final T object = _fromJson<T>(jsonMap);
      return object;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing JSON to object: $e');
      }
      return null;
    }
  }

  T _fromJson<T>(Map<String, dynamic> json) {
    switch (T) {
      // Add cases for custom object types as needed
      default:
        throw ArgumentError('Unsupported type: $T');
    }
  }

  // Method for clearing preferences

  Future<void> clear() async {
    await _prefs.clear();
  }
}
