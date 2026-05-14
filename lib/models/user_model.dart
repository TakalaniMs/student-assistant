class UserModel {
  final String id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      role: map['role'] ?? 'student',
      firstName: map['first_name'],
      lastName: map['last_name'],
    );
  }
}