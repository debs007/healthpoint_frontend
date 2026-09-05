import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../models/order.dart';

class AppointmentService {
  AppointmentService(this._client);

  final ApiClient _client;

  Future<List<Department>> getDepartments() async {
    final response = await _client.get(ApiEndpoints.departments);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Department.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Doctor>> getDoctors({int? departmentId}) async {
    final response = await _client.get(
      ApiEndpoints.doctors,
      query: departmentId != null ? {'department_id': departmentId} : null,
    );
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Doctor> getDoctor(int id) async {
    final response = await _client.get(ApiEndpoints.doctor(id));
    return Doctor.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }

  /// Returns a real Order - the caller hands this straight to the
  /// existing initiatePayment()/verifyPayment() flow, same as a product
  /// or lab test order.
  Future<Order> bookAppointment({
    required int doctorId,
    required int affiliationId,
    required String scheduledDate,
  }) async {
    final response = await _client.post(
      ApiEndpoints.appointmentBookings,
      data: {
        'doctor_id': doctorId,
        'affiliation_id': affiliationId,
        'scheduled_date': scheduledDate,
      },
    );
    return Order.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }
}
