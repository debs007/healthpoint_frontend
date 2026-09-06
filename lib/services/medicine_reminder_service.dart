import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/medicine_reminder.dart';

class MedicineReminderService {
  MedicineReminderService(this._client);

  final ApiClient _client;

  Future<List<MedicineReminder>> getReminders() async {
    final response = await _client.get(ApiEndpoints.medicineReminders);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => MedicineReminder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MedicineReminder> createReminder({
    required String medicineName,
    String? dosageNote,
    required List<String> times,
    required String startDate,
    String? endDate,
  }) async {
    final response = await _client.post(
      ApiEndpoints.medicineReminders,
      data: {
        'medicine_name': medicineName,
        if (dosageNote != null && dosageNote.isNotEmpty) 'dosage_note': dosageNote,
        'times': times,
        'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );
    return MedicineReminder.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }

  Future<void> stopReminder(int id) async {
    await _client.delete(ApiEndpoints.medicineReminder(id));
  }
}
