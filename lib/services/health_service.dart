import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/health_profile.dart';
import '../models/health_record_item.dart';
import '../models/vital.dart';

class HealthService {
  HealthService(this._client);

  final ApiClient _client;

  Future<HealthProfile> getProfile() async {
    final response = await _client.get(ApiEndpoints.healthProfile);
    return HealthProfile.fromJson(response['profile'] as Map<String, dynamic>);
  }

  Future<HealthProfile> updateProfile({
    String? bloodGroup,
    int? heightCm,
    double? weightKg,
    String? dateOfBirth,
    String? gender,
  }) async {
    final response = await _client.put(
      ApiEndpoints.healthProfile,
      data: {
        if (bloodGroup != null) 'blood_group': bloodGroup,
        if (heightCm != null) 'height_cm': heightCm,
        if (weightKg != null) 'weight_kg': weightKg,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
      },
    );
    return HealthProfile.fromJson(response['profile'] as Map<String, dynamic>);
  }

  Future<List<Vital>> getVitals() async {
    final response = await _client.get(ApiEndpoints.vitals);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Vital.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deleteVital(int id) async {
    await _client.delete(ApiEndpoints.vital(id));
  }

  Future<void> recordVitals({
    int? heartRateBpm,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? spo2Percentage,
    double? temperatureFahrenheit,
  }) async {
    await _client.post(
      ApiEndpoints.vitals,
      data: {
        if (heartRateBpm != null) 'heart_rate_bpm': heartRateBpm,
        if (bloodPressureSystolic != null) 'blood_pressure_systolic': bloodPressureSystolic,
        if (bloodPressureDiastolic != null) 'blood_pressure_diastolic': bloodPressureDiastolic,
        if (spo2Percentage != null) 'spo2_percentage': spo2Percentage,
        if (temperatureFahrenheit != null) 'temperature_fahrenheit': temperatureFahrenheit,
      },
    );
  }

  Future<List<HealthRecordItem>> getRecords({String? type}) async {
    final response = await _client.get(
      ApiEndpoints.healthRecords,
      query: {if (type != null) 'type': type},
    );
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => HealthRecordItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Only ever called for a real HealthRecord row (never a
  /// "prescription-{id}" composite entry) - the UI gates this via
  /// HealthRecordItem.isPrescription before ever offering delete.
  Future<void> deleteRecord(String id) async {
    await _client.delete(ApiEndpoints.healthRecord(int.parse(id)));
  }

  /// filePath is optional - a checkup or vaccination note might have
  /// nothing to attach, matching the backend's UploadHealthRecordRequest
  /// (file is nullable there too).
  Future<void> uploadRecord({
    required String type,
    required String title,
    required String recordDate,
    String? filePath,
    String? notes,
  }) async {
    if (filePath != null) {
      await _client.uploadFile(
        ApiEndpoints.healthRecords,
        filePath: filePath,
        fieldName: 'file',
        extraFields: {
          'type': type,
          'title': title,
          'record_date': recordDate,
          if (notes != null) 'notes': notes,
        },
      );
    } else {
      await _client.post(
        ApiEndpoints.healthRecords,
        data: {
          'type': type,
          'title': title,
          'record_date': recordDate,
          if (notes != null) 'notes': notes,
        },
      );
    }
  }
}
