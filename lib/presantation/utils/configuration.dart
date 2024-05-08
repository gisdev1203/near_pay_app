import 'dart:convert';
import 'dart:io';

class Configuration {
  late Map<String, dynamic> _config;

  Configuration._();

  static final Configuration _instance = Configuration._();

  factory Configuration() {
    return _instance;
  }

  Future<void> loadFromFile(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsString();
    _config = jsonDecode(contents);
  }

  dynamic getValue(String key) {
    return _config[key];
  }

  String getString(String key) {
    dynamic value = getValue(key);
    if (value is String) {
      return value;
    }
    throw Exception("Configuration value is not a string");
  }

  int getInt(String key) {
    dynamic value = getValue(key);
    if (value is int) {
      return value;
    }
    throw Exception("Configuration value is not an integer");
  }

  double getDouble(String key) {
    dynamic value = getValue(key);
    if (value is double) {
      return value;
    }
    throw Exception("Configuration value is not a double");
  }

  bool getBool(String key) {
    dynamic value = getValue(key);
    if (value is bool) {
      return value;
    }
    throw Exception("Configuration value is not a boolean");
  }
}
