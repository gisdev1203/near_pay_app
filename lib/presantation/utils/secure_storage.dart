import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> writeData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readData(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAllData() async {
    await _secureStorage.deleteAll();
  }
}

void main() async {
  final secureStorage = SecureStorageService();

  // Writing data
  await secureStorage.writeData('token', 'your_access_token');

  // Reading data
  final token = await secureStorage.readData('token');
  if (kDebugMode) {
    print('Access Token: $token');
  }

  // Deleting data
  await secureStorage.deleteData('token');

  // Deleting all data
  await secureStorage.deleteAllData();
}
