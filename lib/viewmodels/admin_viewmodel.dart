
import 'package:flutter/material.dart';
import '../models/admin_notification_model.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<UserModel> _students = [];
  List<ApplicationModel> _applications = [];
  List<AdminNotificationModel> _notifications = [];
  Map<String, int> _stats = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Filtered student list based on search query
  List<UserModel> _filteredStudents = [];

  List<UserModel> get students => _filteredStudents;
  List<ApplicationModel> get applications => _applications;
  List<AdminNotificationModel> get notifications => _notifications;
  int get unreadNotificationCount =>
      _notifications.where((item) => !item.isRead).length;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _setLoading(true);
    try {
      _stats = await _service.getDashboardStats();
      _students = await _service.getAllStudents();
      _filteredStudents = List.from(_students);
      _applications = await _service.getAllApplications();
      _notifications = await _service.getNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Live search — filters by name, email, or student number
  void searchStudents(String query) {
    if (query.trim().isEmpty) {
      _filteredStudents = List.from(_students);
    } else {
      final q = query.toLowerCase();
      _filteredStudents = _students.where((s) {
        return (s.firstName ?? '').toLowerCase().contains(q) ||
            (s.lastName ?? '').toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            (s.studentNumber ?? '').toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      await _service.updateApplicationStatus(applicationId, status);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    try {
      await _service.deleteApplication(applicationId);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> disableStudent(String studentId) async {
    try {
      await _service.disableStudent(studentId);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String studentId) async {
    try {
      await _service.deleteStudent(studentId);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<ApplicationModel>> getApplicationsByStudent(
      String studentId) async {
    return await _service.getApplicationsByStudent(studentId);
  }

  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _service.getNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _service.markNotificationAsRead(notificationId);
      _notifications = _notifications
          .map(
            (item) => item.id == notificationId
                ? AdminNotificationModel(
                    id: item.id,
                    applicationId: item.applicationId,
                    studentId: item.studentId,
                    title: item.title,
                    message: item.message,
                    isRead: true,
                    createdAt: item.createdAt,
                    application: item.application,
                  )
                : item,
          )
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
