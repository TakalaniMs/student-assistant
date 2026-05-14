
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/views/admin/admin_student_detail_view.dart';
import '../../app_theme.dart';
import '../../models/user_model.dart';
import '../../viewmodels/admin_viewmodel.dart';
// import 'admin_student_detail_view.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({super.key});

  @override
  State<StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

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
          'All Students',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: vm.searchStudents,
              decoration: InputDecoration(
                hintText: 'Search by name, email or student number...',
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.textSecondary, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 18, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          vm.searchStudents('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Student count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  '${vm.students.length} student${vm.students.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Student list
          Expanded(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary))
                : vm.students.isEmpty
                    ? const Center(
                        child: Text('No students found.',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 4),
                        itemCount: vm.students.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _studentTile(context, vm.students[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _studentTile(BuildContext context, UserModel student) {
    final name =
        '${student.firstName ?? ''} ${student.lastName ?? ''}'.trim();
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : student.email[0].toUpperCase();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminStudentDetailView(student: student),
          ),
        ).then((_) => context.read<AdminViewModel>().loadDashboard());
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
            // Avatar with initials
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'No name set' : name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.email,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (student.studentNumber != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      student.studentNumber!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            // Status indicator for disabled accounts
            if (student.role == 'disabled')
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Disabled',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600)),
              )
            else
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}