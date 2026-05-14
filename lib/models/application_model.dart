class ApplicationModule {
  final String academicLevel;
  final String semester;
  final String moduleCode;
  final String moduleName;

  ApplicationModule({
    required this.academicLevel,
    required this.semester,
    required this.moduleCode,
    required this.moduleName,
  });

  Map<String, dynamic> toMap() => {
        'academic_level': academicLevel,
        'semester': semester,
        'module_code': moduleCode,
        'module_name': moduleName,
      };

  factory ApplicationModule.fromMap(Map<String, dynamic> m) =>
      ApplicationModule(
        academicLevel: m['academic_level'],
        semester: m['semester'],
        moduleCode: m['module_code'],
        moduleName: m['module_name'],
      );
}

class ApplicationModel {
  final String? id;
  final String studentId;
  final String yearOfStudy;
  final List<ApplicationModule> modules;
  final bool confirmedEligibility;
  final String? transcriptUrl;
  final String? idDocumentUrl;
  final String? proofOfRegistrationUrl;
  final String status;
  final DateTime? createdAt;
  final Map<String, dynamic>? studentProfile;

  ApplicationModel({
    this.id,
    required this.studentId,
    required this.yearOfStudy,
    required this.modules,
    required this.confirmedEligibility,
    this.transcriptUrl,
    this.idDocumentUrl,
    this.proofOfRegistrationUrl,
    this.status = 'pending',
    this.createdAt,
    this.studentProfile, // now properly in constructor
  });

  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        'year_of_study': yearOfStudy,
        'confirmed_eligibility': confirmedEligibility,
        'transcript_url': transcriptUrl,
        'id_document_url': idDocumentUrl,
        'proof_of_registration_url': proofOfRegistrationUrl,
        'status': status,
      };

  factory ApplicationModel.fromMap(Map<String, dynamic> m) =>
      ApplicationModel(
        id: m['id'],
        studentId: m['student_id'],
        yearOfStudy: m['year_of_study'],
        modules: (m['application_modules'] as List? ?? [])
            .map((e) => ApplicationModule.fromMap(e))
            .toList(),
        confirmedEligibility: m['confirmed_eligibility'] ?? false,
        transcriptUrl: m['transcript_url'],
        idDocumentUrl: m['id_document_url'],
        proofOfRegistrationUrl: m['proof_of_registration_url'],
        status: m['status'] ?? 'pending',
        createdAt: m['created_at'] != null
            ? DateTime.parse(m['created_at'])
            : null,
        studentProfile: m['profiles'],
      );
}