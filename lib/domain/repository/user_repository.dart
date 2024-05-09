
import 'package:near_pay_app/core/models/user.dart';
import 'package:near_pay_app/presantation/services/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final user = await _userService.getUserDetails(userId);
      return user;
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  Future<void> updateUserProfile(User user) async {
    try {
      await _userService.updateUserProfile(user as String, updateUserProfile as dynamic);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Additional methods for user authentication, registration, and other user-related operations can be added here
}
