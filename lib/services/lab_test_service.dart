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

  /// The multi-test equivalent of getCenters() - only centers offering
  /// every selected test qualify, each carrying a totalPrice summed
  /// across all of them (see LabCenter.totalPrice), since a single
  /// per-test price doesn't mean anything once more than one test is
  /// selected.
  Future<List<LabCenter>> getCentersForMultiple(List<int> labTestIds) async {
    final response = await _client.post(ApiEndpoints.labTestCentersForMultiple, data: {'test_ids': labTestIds});
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => LabCenter.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns a real Order - the caller (BookLabTestScreen) hands this
  /// straight to OrderProvider's existing initiatePayment()/verifyPayment()
  /// flow, the same one already used for a product order. Always a list
  /// of test ids now, even for a single test - matches the backend's own
  /// shape, one code path for both cases.
  Future<Order> createBooking({
    required List<int> labTestIds,
    required int labCenterId,
    required String scheduledDate,
    int? addressId,
  }) async {
    final response = await _client.post(
      ApiEndpoints.labTestBookings,
      data: {
        'lab_test_ids': labTestIds,
        'lab_center_id': labCenterId,
        'scheduled_date': scheduledDate,
        if (addressId != null) 'address_id': addressId,
      },
    );
    return Order.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }
}
