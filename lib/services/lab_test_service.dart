import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/lab_test.dart';
import '../models/order.dart';

class LabTestService {
  LabTestService(this._client);

  final ApiClient _client;

  Future<List<LabTest>> getLabTests() async {
    final response = await _client.get(ApiEndpoints.labTests);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => LabTest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DateTime>> getBlockedDates() async {
    final response = await _client.get(ApiEndpoints.labTestBlockedDates);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => DateTime.parse(e as String)).toList();
  }

  /// Returns a real Order - the caller (BookLabTestScreen) hands this
  /// straight to OrderProvider's existing initiatePayment()/verifyPayment()
  /// flow, the same one already used for a product order.
  Future<Order> createBooking({
    required int labTestId,
    required int franchiseId,
    required String scheduledDate,
    int? addressId,
  }) async {
    final response = await _client.post(
      ApiEndpoints.labTestBookings,
      data: {
        'lab_test_id': labTestId,
        'franchise_id': franchiseId,
        'scheduled_date': scheduledDate,
        if (addressId != null) 'address_id': addressId,
      },
    );
    return Order.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }
}
