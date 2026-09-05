import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/lab_center.dart';
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

  /// Centers that actually offer this test - already filtered server-side
  /// by visit type (home-collection support for a home-collection test),
  /// so every center returned here is a valid option to show.
  Future<List<LabCenter>> getCenters(int labTestId) async {
    final response = await _client.get(ApiEndpoints.labTestCenters(labTestId));
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => LabCenter.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns a real Order - the caller (BookLabTestScreen) hands this
  /// straight to OrderProvider's existing initiatePayment()/verifyPayment()
  /// flow, the same one already used for a product order.
  Future<Order> createBooking({
    required int labTestId,
    required int labCenterId,
    required String scheduledDate,
    int? addressId,
  }) async {
    final response = await _client.post(
      ApiEndpoints.labTestBookings,
      data: {
        'lab_test_id': labTestId,
        'lab_center_id': labCenterId,
        'scheduled_date': scheduledDate,
        if (addressId != null) 'address_id': addressId,
      },
    );
    return Order.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }
}
