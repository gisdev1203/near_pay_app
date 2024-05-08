import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationService {
  final String _baseUrl = "https://yourapi.com/auth";
  final storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: "token", value: data["token"]);
        return true;
      } else {
        // Detailed error handling for failed login attempts
        final errorMessage = jsonDecode(response.body)['error'];
        if (kDebugMode) {
          print(errorMessage);
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  // Other methods like register, signOut, isAuthenticated, and getToken remain unchanged

  // Advanced method for refreshing tokens
  Future<bool> refreshToken() async {
    try {
      final token = await storage.read(key: "token");
      if (token == null) {
        return false;
      }
      final response = await http.post(
        Uri.parse('$_baseUrl/refresh_token'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: "token", value: data["token"]);
        return true;
      } else {
        final errorMessage = jsonDecode(response.body)['error'];
        if (kDebugMode) {
          print(errorMessage);
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  // Advanced method for implementing biometric authentication
Future<bool> authenticateWithBiometrics() async {
  // Placeholder implementation for biometric authentication
  // Simulating successful authentication for demonstration purposes
  await Future.delayed(const Duration(seconds: 1)); // Simulate authentication process
  return true; // Return true if authentication is successful
}

// Advanced method for implementing two-factor authentication
Future<bool> authenticateWithTwoFactorAuth() async {
  // Placeholder implementation for two-factor authentication
  // Simulating successful authentication for demonstration purposes
  await Future.delayed(const Duration(seconds: 1)); // Simulate authentication process
  return true; // Return true if authentication is successful
}

// Advanced method for handling email verification
Future<void> sendVerificationEmail(String email) async {
  // Placeholder implementation for sending verification email
  // Simulating sending email for demonstration purposes
  await Future.delayed(const Duration(seconds: 1)); // Simulate sending email process
  if (kDebugMode) {
    print('Verification email sent to $email');
  } // Log email sent
}

// Advanced method for resetting password
Future<void> resetPassword(String email) async {
  // Placeholder implementation for password reset functionality
  // Simulating password reset for demonstration purposes
  await Future.delayed(const Duration(seconds: 1)); // Simulate password reset process
  if (kDebugMode) {
    print('Password reset email sent to $email');
  } // Log password reset email sent
}

}
