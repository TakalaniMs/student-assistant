import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_theme.dart';
import '../../models/application_model.dart';
import '../../models/user_model.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_badge.dart';

class AdminApplicationDetailView extends StatelessWidget {
  final ApplicationModel application;
  final UserModel student;

  const AdminApplicationDetailView({
    super.key,
    required this.application,
    required this.student,
  });

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      AppSnackbar.error(context, 'Document not available.');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not open document.');
      }
    }
  }

  Future<void> _updateStatus(
      BuildContext context, String status) async {
    final label = status == 'approved' ? 'Approve' : 'Reject';
    final confirmed = await ConfirmDialog.show(
      context,
      title: '$label Application',
      message:
          'Are you sure you want to $label this application?',
      confirmText: label,
      isDanger: status == 'rejected',
    );
    if (confirmed && context.mounted) {
      final vm = context.read<AdminViewModel>();
      final success =
          await vm.updateApplicationStatus(application.id!, status);
      if (context.mounted) {
        if (success) {
          AppSnackbar.success(
              context,
              status == 'approved'
                  ? 'Application approved.'
                  : 'Application rejected.');
          Navigator.pop(context);
        } else {
          AppSnackbar.error(context, 'Action failed. Try again.');
        }
      }
    }
  }

  Future<void> _deleteApplication(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Application',
      message:
          'Permanently delete this application? This cannot be undone.',
      confirmText: 'Delete',
      isDanger: true,
    );
    if (confirmed && context.mounted) {
      final vm = context.read<AdminViewModel>();
      final success =
          await vm.deleteApplication(application.id!);
      if (context.mounted) {
        if (success) {
          AppSnackbar.success(context, 'Application deleted.');
          Navigator.pop(context);
        } else {
          AppSnackbar.error(context, 'Delete failed. Try again.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        '${student.firstName ?? ''} ${student.lastName ?? ''}'.trim();
    final isPending = application.status == 'pending';

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
          'Application Details',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          // Delete button always visible for admin
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppTheme.error),
            onPressed: () => _deleteApplication(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
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
                  const Text('Status',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  StatusBadge(status: application.status),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Applicant'),
            const SizedBox(height: 12),
            _infoCard(children: [
              _infoRow('Name',
                  name.isEmpty ? 'Not set' : name),
              const Divider(height: 24),
              _infoRow('Email', student.email),
              const Divider(height: 24),
              _infoRow('Student No.',
                  student.studentNumber ?? 'Not set'),
            ]),

            const SizedBox(height: 24),
            _sectionTitle('Application Info'),
            const SizedBox(height: 12),
            _infoCard(children: [
              _infoRow('Year of Study', application.yearOfStudy),
              const Divider(height: 24),
              _infoRow(
                'Submitted',
                application.createdAt != null
                    ? '${application.createdAt!.day}/${application.createdAt!.month}/${application.createdAt!.year}'
                    : 'N/A',
              ),
              const Divider(height: 24),
              _infoRow('Eligibility Confirmed',
                  application.confirmedEligibility ? 'Yes' : 'No'),
            ]),

            const SizedBox(height: 24),
            _sectionTitle('Applied Modules'),
            const SizedBox(height: 12),
            ...application.modules.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _infoCard(children: [
                      _infoRow(
                          'Module ${e.key + 1}', ''),
                      const SizedBox(height: 8),
                      _infoRow('Code', e.value.moduleCode),
                      const SizedBox(height: 8),
                      _infoRow('Name', e.value.moduleName),
                      const SizedBox(height: 8),
                      _infoRow('Level', e.value.academicLevel),
                      const SizedBox(height: 8),
                      _infoRow('Semester', e.value.semester),
                    ]),
                  ),
                ),

            const SizedBox(height: 24),
            _sectionTitle('Supporting Documents'),
            const SizedBox(height: 12),
            _documentTile(context,
                label: 'Academic Transcript',
                url: application.transcriptUrl),
            const SizedBox(height: 12),
            _documentTile(context,
                label: 'ID Document',
                url: application.idDocumentUrl),
            const SizedBox(height: 12),
            _documentTile(context,
                label: 'Proof of Registration',
                url: application.proofOfRegistrationUrl),

            // Approve / Reject actions for pending only
            if (isPending) ...[
              const SizedBox(height: 32),
              _sectionTitle('Actions'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateStatus(context, 'approved'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        minimumSize: const Size(0, 52),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateStatus(context, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        minimumSize: const Size(0, 52),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(BuildContext context,
      {required String label, required String? url}) {
    final hasUrl = url != null && url.isNotEmpty;
    return GestureDetector(
      onTap: () => _openUrl(context, url),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasUrl
                ? AppTheme.primary.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasUrl
                  ? Icons.insert_drive_file_outlined
                  : Icons.error_outline,
              color: hasUrl
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  Text(
                    hasUrl ? 'Tap to view' : 'Not uploaded',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new,
                size: 16,
                color: hasUrl
                    ? AppTheme.primary
                    : AppTheme.textSecondary),
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
            children: children),
      );

  Widget _infoRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ),
        ],
      );

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          fontFamily: 'Poppins',
        ),
      );
}