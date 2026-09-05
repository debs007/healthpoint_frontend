import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/health_profile.dart';
import '../models/health_record_item.dart';
import '../models/vital.dart';
import '../services/health_service.dart';

class HealthProvider extends ChangeNotifier {
  HealthProvider(this._healthService);

  final HealthService _healthService;

  HealthProfile profile = const HealthProfile();
  List<Vital> vitals = [];
  List<HealthRecordItem> records = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Vital? get latestVital => vitals.isNotEmpty ? vitals.first : null;

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _healthService.getProfile(),
        _healthService.getVitals(),
        _healthService.getRecords(),
      ]);
      profile = results[0] as HealthProfile;
      vitals = results[1] as List<Vital>;
      records = results[2] as List<HealthRecordItem>;
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? bloodGroup,
    int? heightCm,
    double? weightKg,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      profile = await _healthService.updateProfile(
        bloodGroup: bloodGroup,
        heightCm: heightCm,
        weightKg: weightKg,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordVitals({
    int? heartRateBpm,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? spo2Percentage,
    double? temperatureFahrenheit,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      await _healthService.recordVitals(
        heartRateBpm: heartRateBpm,
        bloodPressureSystolic: bloodPressureSystolic,
        bloodPressureDiastolic: bloodPressureDiastolic,
        spo2Percentage: spo2Percentage,
        temperatureFahrenheit: temperatureFahrenheit,
      );
      vitals = await _healthService.getVitals();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVital(int id) async {
    try {
      await _healthService.deleteVital(id);
      vitals = await _healthService.getVitals();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadRecord({
    required String type,
    required String title,
    required String recordDate,
    String? filePath,
    String? notes,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      await _healthService.uploadRecord(
        type: type,
        title: title,
        recordDate: recordDate,
        filePath: filePath,
        notes: notes,
      );
      records = await _healthService.getRecords();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      await _healthService.deleteRecord(id);
      records = await _healthService.getRecords();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
