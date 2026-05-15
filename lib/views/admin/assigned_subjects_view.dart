import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/application_model.dart';
import '../../viewmodels/admin_viewmodel.dart';

class AssignedSubjectsView extends StatefulWidget {
  const AssignedSubjectsView({super.key});

  @override
  State<AssignedSubjectsView> createState() => _AssignedSubjectsViewState();
}

class _AssignedSubjectsViewState extends State<AssignedSubjectsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AdminViewModel>();
      if (vm.applications.isEmpty) {
        vm.loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final subjects = _buildAssignedSubjects(vm.applications);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Assigned Subjects'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: vm.loadDashboard,
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : subjects.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: const [
                      SizedBox(height: 120),
                      Icon(
                        Icons.menu_book_outlined,
                        size: 56,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'No subjects have assigned student assistants yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: subjects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return _subjectCard(subject);
                    },
                  ),
      ),
    );
  }

  List<_AssignedSubject> _buildAssignedSubjects(
    List<ApplicationModel> applications,
  ) {
    final map = <String, _AssignedSubject>{};

    for (final app in applications.where((item) => item.status == 'approved')) {
      final student = _studentName(app);
      final studentNumber = _studentNumber(app);

      for (final module in app.modules) {
        final key = module.moduleCode;
        final subject = map.putIfAbsent(
          key,
          () => _AssignedSubject(
            code: module.moduleCode,
            name: module.moduleName,
            academicLevel: module.academicLevel,
            semester: module.semester,
          ),
        );
        subject.addStudent(
          _AssignedStudent(
            id: app.studentId,
            name: student,
            studentNumber: studentNumber,
          ),
        );
      }
    }

    final subjects = map.values.toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    return subjects;
  }

  String _studentName(ApplicationModel app) {
    final profile = app.studentProfile;
    if (profile == null) return app.studentId;

    final firstName = (profile['first_name'] ?? '').toString().trim();
    final lastName = (profile['last_name'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) return fullName;
    return (profile['email'] ?? app.studentId).toString();
  }

  String _studentNumber(ApplicationModel app) {
    final value = app.studentProfile?['student_number'];
    if (value == null || value.toString().trim().isEmpty) {
      return 'No student number';
    }
    return value.toString();
  }

  Widget _subjectCard(_AssignedSubject subject) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.code,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${subject.academicLevel} - ${subject.semester}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${subject.students.length}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...subject.students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 17,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    student.studentNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedSubject {
  final String code;
  final String name;
  final String academicLevel;
  final String semester;
  final List<_AssignedStudent> students = [];
  final Set<String> _studentIds = {};

  _AssignedSubject({
    required this.code,
    required this.name,
    required this.academicLevel,
    required this.semester,
  });

  void addStudent(_AssignedStudent student) {
    if (_studentIds.add(student.id)) {
      students.add(student);
    }
  }
}

class _AssignedStudent {
  final String id;
  final String name;
  final String studentNumber;

  _AssignedStudent({
    required this.id,
    required this.name,
    required this.studentNumber,
  });
}
