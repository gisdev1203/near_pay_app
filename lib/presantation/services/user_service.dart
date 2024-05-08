import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:near_pay_app/core/models/user.dart';



class UserService with ChangeNotifier {
  User? _currentUser;

  // Simulate a user authentication function
  Future<bool> authenticate(String email, String password) async {
    
    // For demonstration, assuming authentication is always successful
    
    notifyListeners(); // Notify listeners about the change
    return true;
  }

  // Getter to access the current user
  User? get currentUser => _currentUser;

  // Check if the user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Logout function
  void logout() {
    _currentUser = null;
    notifyListeners(); // Notify listeners about the change
  }

  // You can add more user-related functionalities here, such as registration, fetching user profile, etc.
  
  final Dio _dio;

  UserService(this._dio);

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      // Assuming you have an endpoint like /users/{userId} for fetching user details
      final response = await _dio.get('/users/$userId');
      if (response.statusCode == 200) {
        // Assuming the response body is a JSON object representing the user
        return response.data;
      } else {
        // Handle non-200 responses
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Failed to load user details');
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> userProfile) async {
    try {
      // Assuming you have an endpoint like /users/{userId} for updating user profiles
      final response = await _dio.put('/users/$userId', data: jsonEncode(userProfile));
      if (response.statusCode == 200) {
        // Handle successful profile update
        if (kDebugMode) {
          print("User profile updated successfully");
        }
      } else {
        // Handle non-200 responses
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      // Handle any errors that occur during the update
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Failed to update user profile');
    }
  }
}



