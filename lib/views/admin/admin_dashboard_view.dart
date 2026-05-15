import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/models/user_model.dart';
import 'package:student_assistant/views/admin/admin_application_detail_view.dart';
import '../../app_theme.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_view.dart';
import 'assigned_subjects_view.dart';
import 'student_list_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadDashboard();
    });
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
    );

    if (!confirmed || !mounted) return;

    await context.read<AuthViewModel>().logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final user = context.read<AuthViewModel>().user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: vm.loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.firstName ?? 'Admin'}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      color: AppTheme.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (vm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else ...[
                  _statsGrid(vm),
                  const SizedBox(height: 20),
                  _navButton(
                    label: 'View All Students',
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentListView(),
                        ),
                      ).then((_) => vm.loadDashboard());
                    },
                  ),
                  const SizedBox(height: 12),
                  _navButton(
                    label: 'Assigned Subjects',
                    icon: Icons.menu_book_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssignedSubjectsView(),
                        ),
                      ).then((_) => vm.loadDashboard());
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Recent Applications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (vm.applications.isEmpty)
                    _emptyState('No applications yet.')
                  else
                    ...vm.applications.take(5).map(
                          (app) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _applicationCard(app, vm),
                          ),
                        ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statsGrid(AdminViewModel vm) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: [
        _statCard('Total', vm.stats['total'] ?? 0, Icons.folder_open_outlined,
            AppTheme.primary),
        _statCard('Pending', vm.stats['pending'] ?? 0,
            Icons.hourglass_empty_outlined, const Color(0xFFFB8C00)),
        _statCard('Approved', vm.stats['approved'] ?? 0,
            Icons.check_circle_outline, AppTheme.success),
        _statCard('Rejected', vm.stats['rejected'] ?? 0,
            Icons.cancel_outlined, AppTheme.error),
      ],
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _applicationCard(ApplicationModel app, AdminViewModel vm) {
    final name = app.studentProfile != null
        ? '${app.studentProfile!['first_name'] ?? ''} ${app.studentProfile!['last_name'] ?? ''}'
            .trim()
        : app.studentId.substring(0, 8);
    final student = app.studentProfile != null
        ? UserModel.fromMap(app.studentProfile!)
        : UserModel(id: app.studentId, email: '', role: 'student');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name.isEmpty ? 'Unknown Student' : name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(status: app.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            app.modules.isNotEmpty
                ? app.modules.map((m) => m.moduleCode).join(', ')
                : 'No modules',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (app.status == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Approve',
                    color: AppTheme.success,
                    icon: Icons.check,
                    onTap: () =>
                        _updateStatus(context, vm, app.id!, 'approved'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionButton(
                    label: 'Reject',
                    color: AppTheme.error,
                    icon: Icons.close,
                    onTap: () =>
                        _updateStatus(context, vm, app.id!, 'rejected'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          _actionButton(
            label: 'View Application',
            color: AppTheme.primary,
            icon: Icons.visibility_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminApplicationDetailView(
                    application: app,
                    student: student,
                  ),
                ),
              ).then((_) => vm.loadDashboard());
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    AdminViewModel vm,
    String appId,
    String status,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: status == 'approved' ? 'Approve Application' : 'Reject Application',
      message:
          'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} this application?',
      confirmText: status == 'approved' ? 'Approve' : 'Reject',
      isDanger: status == 'rejected',
    );

    if (!confirmed || !context.mounted) return;

    final success = await vm.updateApplicationStatus(appId, status);
    if (!context.mounted) return;

    if (success) {
      AppSnackbar.success(
        context,
        status == 'approved'
            ? 'Application approved.'
            : 'Application rejected.',
      );
    } else {
      AppSnackbar.error(context, 'Action failed. Try again.');
    }
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
    );
  }
}
