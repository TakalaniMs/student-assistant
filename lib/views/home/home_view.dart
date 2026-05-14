import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/views/student/application_detail_view.dart';
import 'package:student_assistant/views/student/application_form_view.dart';
import 'package:student_assistant/views/student/profile_view.dart';
import '../../app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../auth/login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Load application on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().loadApplication();
    });
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      isDanger: false,
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
    final authVm = context.watch<AuthViewModel>();
    final appVm = context.watch<ApplicationViewModel>();
    final user = authVm.user;
    final application = appVm.application;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          // Pull to refresh reloads application data
          onRefresh: () => appVm.loadApplication(),
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
                          'Hello, ${user?.firstName ?? 'Student'}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Text(
                          'Student Assistant Portal',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Profile avatar — tap to go to profile
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileView()),
                        );
                        // Reload in case name was updated
                        setState(() {});
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (user?.email ?? 'S')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Status summary card
                _summaryCard(application?.status),

                const SizedBox(height: 28),

                // Section title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    // Logout button
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout,
                          size: 16, color: AppTheme.textSecondary),
                      label: const Text('Logout',
                          style: TextStyle(
                              color: AppTheme.surface,
                              fontSize: 13)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Application content
                if (appVm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                          color: AppTheme.primary),
                    ),
                  )
                else if (application == null)
                  _noApplicationCard()
                else
                  _applicationCard(application, appVm),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top summary card showing overall status
  Widget _summaryCard(String? status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Status',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status == null
                ? 'No Application Yet'
                : status[0].toUpperCase() + status.substring(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            status == null
                ? 'You have not submitted an application yet.'
                : status == 'pending'
                    ? 'Your application is under review.'
                    : status == 'approved'
                        ? 'Congratulations! Your application was approved.'
                        : 'Your application was not successful this time.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Card shown when no application exists
  Widget _noApplicationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              size: 56, color: AppTheme.primaryLight),
          const SizedBox(height: 16),
          const Text(
            'No Application Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Apply for a Student Assistant position\nand track your progress here.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.6),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final submitted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => const ApplicationFormView()),
              );
              if (submitted == true && mounted) {
                context.read<ApplicationViewModel>().loadApplication();
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  // Card shown when application exists
  Widget _applicationCard(application, ApplicationViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.inputFill,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Application',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary,
                  ),
                ),
                StatusBadge(status: application.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Year of Study', application.yearOfStudy),
                const SizedBox(height: 12),

                // List applied modules
                ...application.modules.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _infoRow(
                          'Module ${e.key + 1}',
                          '${e.value.moduleCode} — ${e.value.moduleName}',
                        ),
                      ),
                    ),

                const SizedBox(height: 12),
                _infoRow(
                  'Submitted',
                  application.createdAt != null
                      ? '${application.createdAt!.day}/${application.createdAt!.month}/${application.createdAt!.year}'
                      : 'N/A',
                ),

                const SizedBox(height: 20),

                // View details button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicationDetailView(
                            application: application),
                      ),
                    ).then((_) => vm.loadApplication());
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(
                        color: AppTheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
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
}