

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ChangeNotifier lets Provider rebuild listening widgets on state change
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _user = await _authService.login(email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add this method inside AuthViewModel, after logout()

Future<void> sendPasswordReset(String email) async {
  await Supabase.instance.client.auth.resetPasswordForEmail(email);
}

  Future<bool> register(String email, String password) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _user = await _authService.register(email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}