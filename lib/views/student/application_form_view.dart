
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../data/modules_data.dart';
import '../../models/application_model.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_snackbar.dart';

class ApplicationFormView extends StatefulWidget {
  final ApplicationModel? existing;
  const ApplicationFormView({super.key, this.existing});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  final _formKey = GlobalKey<FormState>();

  String? _yearOfStudy;
  bool _confirmedEligibility = false;

  String? _level1, _semester1, _moduleCode1;

  bool _addSecondModule = false;
  String? _level2, _semester2, _moduleCode2;

  // Bytes-based file storage for web compatibility
  Uint8List? _transcriptBytes;
  String? _transcriptName;
  Uint8List? _idDocumentBytes;
  String? _idDocumentName;
  Uint8List? _proofBytes;
  String? _proofName;

  bool get _isEditing => widget.existing != null;

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year'];
  final List<String> _levels = ['1st Year', '2nd Year', '3rd Year'];
  final List<String> _semesters = ['Semester 1', 'Semester 2'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) _prefill();
  }

  void _prefill() {
    final a = widget.existing!;
    _yearOfStudy = a.yearOfStudy;
    _confirmedEligibility = a.confirmedEligibility;
    if (a.modules.isNotEmpty) {
      _level1 = a.modules[0].academicLevel;
      _semester1 = a.modules[0].semester;
      _moduleCode1 = a.modules[0].moduleCode;
    }
    if (a.modules.length > 1) {
      _addSecondModule = true;
      _level2 = a.modules[1].academicLevel;
      _semester2 = a.modules[1].semester;
      _moduleCode2 = a.modules[1].moduleCode;
    }
  }

  Future<void> _pickFile(Function(Uint8List bytes, String name) onPicked) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // loads bytes directly — required for web
    );
    if (result != null && result.files.single.bytes != null) {
      onPicked(result.files.single.bytes!, result.files.single.name);
      setState(() {});
    }
  }

  List<Map<String, String>> _getModules(String? level, String? semester) {
    if (level == null || semester == null) return [];
    return kModules[level]?[semester] ?? [];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_yearOfStudy == null) {
      AppSnackbar.error(context, 'Select your current year of study.');
      return;
    }
    if (_level1 == null || _semester1 == null || _moduleCode1 == null) {
      AppSnackbar.error(context, 'Please complete Module 1 selection.');
      return;
    }
    if (_addSecondModule &&
        (_level2 == null || _semester2 == null || _moduleCode2 == null)) {
      AppSnackbar.error(context, 'Please complete Module 2 or remove it.');
      return;
    }
    if (!_confirmedEligibility) {
      AppSnackbar.error(context, 'You must confirm your eligibility.');
      return;
    }
    if (!_isEditing &&
        (_transcriptBytes == null ||
            _idDocumentBytes == null ||
            _proofBytes == null)) {
      AppSnackbar.error(context, 'Please upload all three required documents.');
      return;
    }

    final uid = context.read<AuthViewModel>().user!.id;

    final modules = <ApplicationModule>[];
    final mod1 = _getModules(_level1, _semester1)
        .firstWhere((m) => m['code'] == _moduleCode1);
    modules.add(ApplicationModule(
      academicLevel: _level1!,
      semester: _semester1!,
      moduleCode: _moduleCode1!,
      moduleName: mod1['name']!,
    ));

    if (_addSecondModule && _moduleCode2 != null) {
      final mod2 = _getModules(_level2, _semester2)
          .firstWhere((m) => m['code'] == _moduleCode2);
      modules.add(ApplicationModule(
        academicLevel: _level2!,
        semester: _semester2!,
        moduleCode: _moduleCode2!,
        moduleName: mod2['name']!,
      ));
    }

    final application = ApplicationModel(
      studentId: uid,
      yearOfStudy: _yearOfStudy!,
      modules: modules,
      confirmedEligibility: _confirmedEligibility,
    );

    final vm = context.read<ApplicationViewModel>();
    bool success;

    if (_isEditing) {
      success = await vm.updateApplication(
        applicationId: widget.existing!.id!,
        application: application,
        transcriptBytes: _transcriptBytes,
        transcriptName: _transcriptName,
        idDocumentBytes: _idDocumentBytes,
        idDocumentName: _idDocumentName,
        proofBytes: _proofBytes,
        transcryptBytes: _transcriptBytes,
        proofName: _proofName,
      );
    } else {
      success = await vm.submitApplication(
        
        application: application,
        transcriptBytes: _transcriptBytes!,
        transcriptName: _transcriptName!,
        idDocumentBytes: _idDocumentBytes!,
        idDocumentName: _idDocumentName!,
        proofBytes: _proofBytes!,
        proofName: _proofName!,
      );
    }

    if (!mounted) return;

    if (success) {
      AppSnackbar.success(
          context,
          _isEditing
              ? 'Application updated successfully!'
              : 'Application submitted successfully!');
      Navigator.pop(context, true);
    } else {
      AppSnackbar.error(context, vm.errorMessage ?? 'Submission failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApplicationViewModel>();

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
        title: Text(
          _isEditing ? 'Edit Application' : 'Apply Now',
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Personal Info'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _yearOfStudy,
                decoration: _dropdownDecoration(
                    'Current Year of Study', Icons.school_outlined),
                items: _years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) => setState(() => _yearOfStudy = v),
              ),
              const SizedBox(height: 28),
              _sectionTitle('Module 1'),
              const SizedBox(height: 12),
              _moduleSelector(
                level: _level1,
                semester: _semester1,
                moduleCode: _moduleCode1,
                onLevelChanged: (v) => setState(
                    () => {_level1 = v, _semester1 = null, _moduleCode1 = null}),
                onSemesterChanged: (v) =>
                    setState(() => {_semester1 = v, _moduleCode1 = null}),
                onModuleChanged: (v) => setState(() => _moduleCode1 = v),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() {
                  _addSecondModule = !_addSecondModule;
                  if (!_addSecondModule) {
                    _level2 = _semester2 = _moduleCode2 = null;
                  }
                }),
                child: Row(
                  children: [
                    Icon(
                      _addSecondModule
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _addSecondModule
                          ? 'Remove second module'
                          : 'Add a second module (optional)',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (_addSecondModule) ...[
                const SizedBox(height: 20),
                _sectionTitle('Module 2'),
                const SizedBox(height: 12),
                _moduleSelector(
                  level: _level2,
                  semester: _semester2,
                  moduleCode: _moduleCode2,
                  onLevelChanged: (v) => setState(
                      () => {_level2 = v, _semester2 = null, _moduleCode2 = null}),
                  onSemesterChanged: (v) =>
                      setState(() => {_semester2 = v, _moduleCode2 = null}),
                  onModuleChanged: (v) => setState(() => _moduleCode2 = v),
                ),
              ],
              const SizedBox(height: 28),
              _sectionTitle('Supporting Documents'),
              const SizedBox(height: 4),
              const Text('Upload PDF, JPG, or PNG files.',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              _filePickerTile(
                label: 'Academic Transcript',
                fileName: _transcriptName,
                existingUrl:
                    _isEditing ? widget.existing!.transcriptUrl : null,
                onTap: () => _pickFile(
                    (b, n) => setState(() {
                          _transcriptBytes = b;
                          _transcriptName = n;
                        })),
              ),
              const SizedBox(height: 12),
              _filePickerTile(
                label: 'ID Document',
                fileName: _idDocumentName,
                existingUrl:
                    _isEditing ? widget.existing!.idDocumentUrl : null,
                onTap: () => _pickFile(
                    (b, n) => setState(() {
                          _idDocumentBytes = b;
                          _idDocumentName = n;
                        })),
              ),
              const SizedBox(height: 12),
              _filePickerTile(
                label: 'Proof of Registration',
                fileName: _proofName,
                existingUrl: _isEditing
                    ? widget.existing!.proofOfRegistrationUrl
                    : null,
                onTap: () => _pickFile(
                    (b, n) => setState(() {
                          _proofBytes = b;
                          _proofName = n;
                        })),
              ),
              const SizedBox(height: 28),
              _sectionTitle('Eligibility Confirmation'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: CheckboxListTile(
                  value: _confirmedEligibility,
                  onChanged: (v) =>
                      setState(() => _confirmedEligibility = v ?? false),
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  title: const Text(
                    'I confirm that I meet the minimum requirements for the selected module(s) and that all information provided is accurate.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),),
                child: vm.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(_isEditing
                        ? 'Update Application'
                        : 'Submit Application'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moduleSelector({
    required String? level,
    required String? semester,
    required String? moduleCode,
    required ValueChanged<String?> onLevelChanged,
    required ValueChanged<String?> onSemesterChanged,
    required ValueChanged<String?> onModuleChanged,
  }) {
    final modules = _getModules(level, semester);
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: level,
          decoration:
              _dropdownDecoration('Academic Level', Icons.layers_outlined),
          items: _levels
              .map((l) => DropdownMenuItem(value: l, child: Text(l)))
              .toList(),
          onChanged: onLevelChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: semester,
          decoration: _dropdownDecoration(
              'Semester', Icons.calendar_today_outlined),
          items: _semesters
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: level != null ? onSemesterChanged : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: moduleCode,
          decoration: _dropdownDecoration('Module', Icons.book_outlined),
          isExpanded: true,
          items: modules
              .map((m) => DropdownMenuItem(
                    value: m['code'],
                    child: Text('${m['code']} — ${m['name']}',
                        overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: semester != null ? onModuleChanged : null,
        ),
      ],
    );
  }

  Widget _filePickerTile({
    required String label,
    required String? fileName,
    required VoidCallback onTap,
    String? existingUrl,
  }) {
    final hasFile = fileName != null;
    final hasExisting = existingUrl != null && existingUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasFile
              ? AppTheme.primary.withOpacity(0.08)
              : AppTheme.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile ? AppTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile
                  ? Icons.check_circle
                  : Icons.upload_file_outlined,
              color: hasFile
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
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: hasFile
                              ? AppTheme.primary
                              : AppTheme.textPrimary)),
                  if (hasFile)
                    Text(fileName,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis)
                  else if (hasExisting)
                    const Text('Already uploaded — tap to replace',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary))
                  else
                    const Text('Tap to upload',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 20),
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

  InputDecoration _dropdownDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      );
}