import 'user_role.dart';

class AppUser {
  final String id;
  final String name;
  final String username;
  final String password;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'password': password,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: UserRole.fromString(json['role'] as String),
    );
  }
}
