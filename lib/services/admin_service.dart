
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_notification_model.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';

class AdminService {
  final _client = Supabase.instance.client;

  // Fetch all profiles with role 'student'
  Future<List<UserModel>> getAllStudents() async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('role', 'student')
        .order('first_name', ascending: true);

    return (data as List).map((e) => UserModel.fromMap(e)).toList();
  }

  // Fetch all applications with their modules and student profile
  Future<List<ApplicationModel>> getAllApplications() async {
    final data = await _client
        .from('applications')
        .select('*, application_modules(*), profiles(*)')
        .order('created_at', ascending: false);

    return (data as List).map((e) => ApplicationModel.fromMap(e)).toList();
  }

  Future<List<AdminNotificationModel>> getNotifications() async {
    final data = await _client
        .from('admin_notifications')
        .select('*, applications(*, application_modules(*), profiles(*))')
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => AdminNotificationModel.fromMap(e))
        .toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('admin_notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // Fetch a single student's profile
  Future<UserModel> getStudentById(String studentId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', studentId)
        .single();
    return UserModel.fromMap(data);
  }

  // Fetch all applications belonging to a specific student
  Future<List<ApplicationModel>> getApplicationsByStudent(
      String studentId) async {
    final data = await _client
        .from('applications')
        .select('*, application_modules(*)')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => ApplicationModel.fromMap(e)).toList();
  }

  // Update application status — 'approved' or 'rejected'
  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    await _client
        .from('applications')
        .update({'status': status})
        .eq('id', applicationId);
  }

  // Delete any application as admin
  Future<void> deleteApplication(String applicationId) async {
    await _client
        .from('applications')
        .delete()
        .eq('id', applicationId);
  }

  // Disable a student account by setting role to 'disabled'
  Future<void> disableStudent(String studentId) async {
    await _client
        .from('profiles')
        .update({'role': 'disabled'})
        .eq('id', studentId);
  }

  // Permanently delete a student profile (cascades to applications)
  Future<void> deleteStudent(String studentId) async {
    await _client
        .from('profiles')
        .delete()
        .eq('id', studentId);
  }

  // Summary counts for dashboard cards
  Future<Map<String, int>> getDashboardStats() async {
    final apps = await _client
        .from('applications')
        .select('status');

    final total = (apps as List).length;
    final pending =
        apps.where((a) => a['status'] == 'pending').length;
    final approved =
        apps.where((a) => a['status'] == 'approved').length;
    final rejected =
        apps.where((a) => a['status'] == 'rejected').length;

    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}
