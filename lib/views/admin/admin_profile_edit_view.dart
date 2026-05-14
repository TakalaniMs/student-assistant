import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_theme.dart';
import '../../models/user_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/auth_text_field.dart';

class AdminProfileEditView extends StatefulWidget {
  final UserModel student;

  const AdminProfileEditView({super.key, required this.student});

  @override
  State<AdminProfileEditView> createState() =>
      _AdminProfileEditViewState();
}

class _AdminProfileEditViewState extends State<AdminProfileEditView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _studentNumberCtrl;
  late final TextEditingController _phoneCtrl;
  String? _selectedYear;
  String? _selectedRole;
  bool _isSaving = false;

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year'];
  final List<String> _roles = ['student', 'admin', 'disabled'];

  @override
  void initState() {
    super.initState();
    _firstNameCtrl =
        TextEditingController(text: widget.student.firstName ?? '');
    _lastNameCtrl =
        TextEditingController(text: widget.student.lastName ?? '');
    _studentNumberCtrl =
        TextEditingController(text: widget.student.studentNumber ?? '');
    _phoneCtrl =
        TextEditingController(text: widget.student.phone ?? '');
    _selectedYear = widget.student.yearOfStudy;
    _selectedRole = widget.student.role;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _studentNumberCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // Admin directly updates any student profile via Supabase
      await Supabase.instance.client.from('profiles').update({
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'student_number': _studentNumberCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'year_of_study': _selectedYear,
        'role': _selectedRole,
      }).eq('id', widget.student.id);

      if (mounted) {
        AppSnackbar.success(context, 'Profile updated successfully.');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to update profile.');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Student Profile',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthTextField(
                label: 'First Name',
                controller: _firstNameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Last Name',
                controller: _lastNameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Student Number',
                controller: _studentNumberCtrl,
                prefixIcon: Icons.badge_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Year of study dropdown
              DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'Year of Study',
                  filled: true,
                  fillColor: AppTheme.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.school_outlined,
                      color: AppTheme.textSecondary, size: 20),
                ),
                items: _years
                    .map((y) =>
                        DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
              ),
              const SizedBox(height: 16),

              // Role dropdown — admin can change role directly
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Account Role',
                  filled: true,
                  fillColor: AppTheme.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.manage_accounts_outlined,
                      color: AppTheme.textSecondary, size: 20),
                ),
                items: _roles
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Save Changes'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}