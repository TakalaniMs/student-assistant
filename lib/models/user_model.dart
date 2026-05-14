class UserModel {
  final String id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? studentNumber;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.studentNumber
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      role: map['role'] ?? 'student',
      firstName: map['first_name'],
      lastName: map['last_name'],
      studentNumber: map['student_number'],
    );
  }
}