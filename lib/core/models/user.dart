import 'package:meta/meta.dart'; // For @immutable annotation

@immutable
class User {
  final String id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String walletAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.walletAddress,
    required this.createdAt,
    // ignore: non_constant_identifier_names
    required this.updatedAt, required String name, required String DateTime,
  })  : assert(id.isNotEmpty),
        assert(username.isNotEmpty),
        assert(email.isNotEmpty),
        assert(walletAddress.isNotEmpty);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      walletAddress: json['walletAddress'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(), name: '', DateTime: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'walletAddress': walletAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
