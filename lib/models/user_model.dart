// Maps the Supabase `profiles` table row to a Dart object
class UserModel {
  final String id;
  final String email;
  final String role; // 'student' or 'admin' — drives post-login routing

  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      role: map['role'] ?? 'student',
    );
  }
}