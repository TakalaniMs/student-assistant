

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  // Signs up and inserts a row into the `profiles` table with default role 'student'
  Future<UserModel> register(String email, String password) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final uid = res.user!.id;

    await _client.from('profiles').insert({
      'id': uid,
      'email': email,
      'role': 'student',
    });

    return UserModel(id: uid, email: email, role: 'student');
  }

  Future<UserModel> login(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final uid = res.user!.id;

    // Fetch the profile to get the stored role
    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();

    return UserModel.fromMap(profile);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // Checks if a session already exists on app launch
  User? get currentUser => _client.auth.currentUser;
}