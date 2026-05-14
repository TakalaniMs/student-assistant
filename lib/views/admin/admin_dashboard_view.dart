import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/application_model.dart';
import '../../app_theme.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_view.dart';
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
    if (confirmed && mounted) {
      await context.read<AuthViewModel>().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
        (_) => false,
      );
    }
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
          onRefresh: () => vm.loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.firstName ?? 'Admin'} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Text(
                          'Admin Portal',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Logout
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Stats cards
                if (vm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: CircularProgressIndicator(
                          color: AppTheme.primary),
                    ),
                  )
                else ...[
                  // 2x2 stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _statCard('Total', vm.stats['total'] ?? 0,
                          Icons.folder_open_outlined, AppTheme.primary),
                      _statCard('Pending', vm.stats['pending'] ?? 0,
                          Icons.hourglass_empty_outlined,
                          const Color(0xFFFB8C00)),
                      _statCard('Approved', vm.stats['approved'] ?? 0,
                          Icons.check_circle_outline, AppTheme.success),
                      _statCard('Rejected', vm.stats['rejected'] ?? 0,
                          Icons.cancel_outlined, AppTheme.error),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // View all students button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StudentListView()),
                      ).then((_) => vm.loadDashboard());
                    },
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('View All Students'),
                  ),

                  const SizedBox(height: 28),

                  // Recent applications
                  const Text(
                    'Recent Applications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (vm.applications.isEmpty)
                    _emptyState('No applications yet.')
                  else
                    // Show latest 5 applications
                    ...vm.applications.take(5).map(
                          (app) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _applicationCard(app, vm),
                          ),
                        ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _applicationCard(ApplicationModel app, AdminViewModel vm) {
    // Get student name from profile embedded in application
    final name = app.studentProfile != null
    ? '${app.studentProfile!['first_name'] ?? ''} ${app.studentProfile!['last_name'] ?? ''}'.trim()
    : app.studentId.substring(0, 8);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ? app.modules
                    .map((m) => m.moduleCode)
                    .join(', ')
                : 'No modules',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),

          // Approve / Reject buttons — only for pending
          if (app.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Approve',
                    color: AppTheme.success,
                    icon: Icons.check,
                    onTap: () => _updateStatus(
                        context, vm, app.id!, 'approved'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionButton(
                    label: 'Reject',
                    color: AppTheme.error,
                    icon: Icons.close,
                    onTap: () => _updateStatus(
                        context, vm, app.id!, 'rejected'),
                  ),
                ),
              ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, AdminViewModel vm,
      String appId, String status) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: status == 'approved' ? 'Approve Application' : 'Reject Application',
      message: 'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} this application?',
      confirmText: status == 'approved' ? 'Approve' : 'Reject',
      isDanger: status == 'rejected',
    );
    if (confirmed && context.mounted) {
      final success = await vm.updateApplicationStatus(appId, status);
      if (context.mounted) {
        if (success) {
          AppSnackbar.success(
              context,
              status == 'approved'
                  ? 'Application approved.'
                  : 'Application rejected.');
        } else {
          AppSnackbar.error(context, 'Action failed. Try again.');
        }
      }
    }
  }

  Widget _emptyState(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(message,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ),
      );
}