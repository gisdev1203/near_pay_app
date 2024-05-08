import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

class SecurityService {
  final AesGcm algorithm = AesGcm.with256bits();
  
  get nonce => null; 
  get mac  => null; 
  // Use AES-GCM for encryption

  /// Encrypts data using AES-GCM encryption.
  ///
  /// [data]: The data to encrypt.
  /// [key]: The secret key used for encryption.
  Future<String> encryptData(String data, SecretKey key) async {
    try {
      // Generate a random nonce for encryption
      final nonce = algorithm.newNonce();

      // Perform encryption
      final encryptedBytes = await algorithm.encrypt(
        utf8.encode(data), // Convert data to bytes
        secretKey: key,
        nonce: nonce,
      );

      // Encode encrypted bytes as base64 for easy storage/transmission
      return base64.encode(encryptedBytes as List<int>);
    } catch (e) {
      // Handle encryption errors
      if (kDebugMode) {
        print('Encryption failed: $e');
      }
      rethrow; // Rethrow the exception for upstream handling
    }
  }

  /// Decrypts data using AES-GCM decryption.
  ///
  /// [encryptedData]: The encrypted data to decrypt.
  /// [key]: The secret key used for decryption.
  Future<String> decryptData(String encryptedData, SecretKey key) async {
    try {
      // Decode encrypted data from base64
      final encryptedBytes = base64.decode(encryptedData);

      // Perform decryption
     final decryptedBytes = await algorithm.decrypt(
  SecretBox(encryptedBytes, nonce: nonce, mac: mac), // Provide an empty MAC
  secretKey: key,
);


      // Convert decrypted bytes back to string
      return utf8.decode(decryptedBytes);
    } catch (e) {
      // Handle decryption errors
      if (kDebugMode) {
        print('Decryption failed: $e');
      }
      rethrow; // Rethrow the exception for upstream handling
    }
  }

  /// Generates a secure random key for encryption/decryption.
  Future<SecretKey> generateSecureKey() async {
    try {
      // Generate a random secret key using a secure random number generator
      final keyData = await algorithm.newSecretKey();

      // Return the generated key
      return keyData;
    } catch (e) {
      // Handle key generation errors
      if (kDebugMode) {
        print('Key generation failed: $e');
      }
      rethrow; // Rethrow the exception for upstream handling
    }
  }
}
