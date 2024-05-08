import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String path) async {
    try {
      final TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<List<int>> downloadFile(String path) async {
    try {
      final Reference ref = _storage.ref(path);
      final List<int> bytes = (await ref.getData()) as List<int>;
      return bytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      rethrow;
    }
  }

  Future<void> setMetadata(String path, Map<String, String> metadata) async {
  try {
    await _storage.ref(path).getMetadata();
  } catch (e) {
    if (kDebugMode) {
      print('Error setting metadata: $e');
    }
    rethrow;
  }
}


  Future<FullMetadata> getMetadata(String path) async {
    try {
      final FullMetadata metadata = await _storage.ref(path).getMetadata();
      return metadata;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting metadata: $e');
      }
      rethrow;
    }
  }
}
