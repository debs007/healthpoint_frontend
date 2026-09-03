import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/prescription.dart';

class PrescriptionService {
  PrescriptionService(this._client);

  final ApiClient _client;

  Future<List<Prescription>> getPrescriptions() async {
    final response = await _client.get(ApiEndpoints.prescriptions);
    final data = response['prescriptions'] as List<dynamic>? ?? [];
    return data.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Field name is 'file', not 'image' - confirmed against the actual
  /// UploadPrescriptionRequest validation rules, not guessed.
  Future<void> upload(String filePath) async {
    await _client.uploadFile(
      ApiEndpoints.prescriptions,
      filePath: filePath,
      fieldName: 'file',
    );
  }
}
