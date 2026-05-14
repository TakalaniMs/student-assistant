import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile() async {
    final uid = _client.auth.currentUser!.id;
    return await _client.from('profiles').select().eq('id', uid).single();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String studentNumber,
    required String yearOfStudy,
    required String phone,
  }) async {
    final uid = _client.auth.currentUser!.id;

    await _client
        .from('profiles')
        .update({
          'first_name': firstName,
          'last_name': lastName,
          'student_number': studentNumber,
          'year_of_study': yearOfStudy,
          'phone': phone,
        })
        .eq('id', uid); // make sure this line is here
  }
}
