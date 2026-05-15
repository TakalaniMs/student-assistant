import 'application_model.dart';

class AdminNotificationModel {
  final String id;
  final String applicationId;
  final String studentId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final ApplicationModel? application;

  AdminNotificationModel({
    required this.id,
    required this.applicationId,
    required this.studentId,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.application,
  });

  factory AdminNotificationModel.fromMap(Map<String, dynamic> map) {
    return AdminNotificationModel(
      id: map['id'],
      applicationId: map['application_id'],
      studentId: map['student_id'],
      title: map['title'] ?? 'New application submitted',
      message: map['message'] ?? 'A student submitted a new application.',
      isRead: map['is_read'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      application: map['applications'] != null
          ? ApplicationModel.fromMap(
              Map<String, dynamic>.from(map['applications']),
            )
          : null,
    );
  }
}
