

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  final ApplicationService _service = ApplicationService();

  ApplicationModel? _application;
  bool _isLoading = false;
  String? _errorMessage;

  ApplicationModel? get application => _application;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> loadApplication() async {
    _setLoading(true);
    try {
      _application = await _service.getMyApplication();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitApplication({
    required ApplicationModel application,
    required Uint8List transcriptBytes,
    required String transcriptName,
    required Uint8List idDocumentBytes,
    required String idDocumentName,
    required Uint8List proofBytes,
    required String proofName,
  }) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      final exists = await _service.hasExistingApplication();
      if (exists) {
        _errorMessage = 'You already have a submitted application.';
        return false;
      }
      _application = await _service.submitApplication(
        application: application,
        transcriptBytes: transcriptBytes,
        transcriptName: transcriptName,
        idDocumentBytes: idDocumentBytes,
        idDocumentName: idDocumentName,
        proofBytes: proofBytes,
        proofName: proofName,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateApplication({
    required String applicationId,
    required ApplicationModel application,
    Uint8List? transcriptBytes,
    String? transcriptName,
    Uint8List? idDocumentBytes,
    String? idDocumentName,
    Uint8List? proofBytes,
    String? proofName,
    Uint8List? transcryptBytes,
  }) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      await _service.updateApplication(
        applicationId: applicationId,
        application: application,
        transcriptBytes: transcryptBytes,
        transcriptName: transcriptName,
        idDocumentBytes: idDocumentBytes,
        idDocumentName: idDocumentName,
        proofBytes: proofBytes,
        proofName: proofName,
      );
      await loadApplication();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      await _service.deleteApplication(applicationId);
      _application = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}