import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/application_model.dart';
import '../../models/user_model.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_badge.dart';
import 'admin_application_detail_view.dart';

class AdminStudentDetailView extends StatefulWidget {
  final UserModel student;

  const AdminStudentDetailView({super.key, required this.student});

  @override
  State<AdminStudentDetailView> createState() => _AdminStudentDetailViewState();
}

class _AdminStudentDetailViewState extends State<AdminStudentDetailView> {
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      _applications = await context
          .read<AdminViewModel>()
          .getApplicationsByStudent(widget.student.id);
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disableAccount() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Disable Account',
      message:
          'This will prevent ${widget.student.firstName ?? 'this student'} from logging in. You can re-enable them later by updating their role.',
      confirmText: 'Disable',
      isDanger: true,
    );
    if (confirmed && mounted) {
      final success = await context.read<AdminViewModel>().disableStudent(
        widget.student.id,
      );
      if (mounted) {
        if (success) {
          AppSnackbar.success(context, 'Account disabled successfully.');
          Navigator.pop(context);
        } else {
          AppSnackbar.error(context, 'Failed to disable account.');
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Account',
      message:
          'This will permanently delete ${widget.student.firstName ?? 'this student'}\'s account and all their applications. This cannot be undone.',
      confirmText: 'Delete',
      isDanger: true,
    );
    if (confirmed && mounted) {
      final success = await context.read<AdminViewModel>().deleteStudent(
        widget.student.id,
      );
      if (mounted) {
        if (success) {
          AppSnackbar.success(context, 'Account deleted successfully.');
          Navigator.pop(context);
        } else {
          AppSnackbar.error(context, 'Failed to delete account.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final name = '${student.firstName ?? ''} ${student.lastName ?? ''}'.trim();
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : student.email[0].toUpperCase();
    final isDisabled = student.role == 'disabled';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Details',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name.isEmpty ? 'No name set' : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  if (isDisabled) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.error.withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        'Account Disabled',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Profile Information'),
            const SizedBox(height: 12),

            _infoCard(
              children: [
                _infoRow('Student No.', student.studentNumber ?? 'Not set'),
                const Divider(height: 24),
                _infoRow('Year of Study', student.yearOfStudy ?? 'Not set'),
                const Divider(height: 24),
                _infoRow('Phone', student.phone ?? 'Not set'),
                const Divider(height: 24),
                _infoRow('Account Role', student.role),
              ],
            ),

            const SizedBox(height: 24),
            _sectionTitle('Applications'),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            else if (_applications.isEmpty)
              _emptyApplications()
            else
              ..._applications.map(
                (app) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _applicationTile(context, app),
                ),
              ),

            const SizedBox(height: 28),
            _sectionTitle('Account Management'),
            const SizedBox(height: 12),

            // Disable account button
            if (!isDisabled)
              _dangerButton(
                label: 'Disable Account',
                subtitle: 'Prevent this student from logging in.',
                icon: Icons.block_outlined,
                color: const Color(0xFFFB8C00),
                onTap: _disableAccount,
              ),

            if (!isDisabled) const SizedBox(height: 12),

            // Delete account button
            _dangerButton(
              label: 'Delete Account',
              subtitle: 'Permanently remove this student and all their data.',
              icon: Icons.delete_forever_outlined,
              color: AppTheme.error,
              onTap: _deleteAccount,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
      fontFamily: 'Poppins',
    ),
  );
  Widget _applicationTile(BuildContext context, ApplicationModel app) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminApplicationDetailView(
              application: app,
              student: widget.student,
            ),
          ),
        ).then((_) => _loadApplications());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.modules.isNotEmpty
                        ? app.modules.map((m) => m.moduleCode).join(', ')
                        : 'No modules',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Year: ${app.yearOfStudy}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(status: app.status),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _infoRow(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 130,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    ],
  );

  Widget _emptyApplications() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      children: [
        Icon(Icons.inbox_outlined, size: 40, color: AppTheme.primaryLight),
        SizedBox(height: 8),
        Text(
          'No applications submitted.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _dangerButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
