// lib/models/user_model.dart

class User {
  final String? id;
  final String name;
  final String email;

  User({
    this.id,
    required this.name,
    required this.email,
  });
}