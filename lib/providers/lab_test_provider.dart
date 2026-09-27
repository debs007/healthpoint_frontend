import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/lab_center.dart';
import '../models/lab_test.dart';
import '../models/order.dart';
import '../services/lab_test_service.dart';

class LabTestProvider extends ChangeNotifier {
  LabTestProvider(this._service);

  final LabTestService _service;

  List<LabTest> tests = [];
  List<DateTime> blockedDates = [];
  bool isLoading = false;
  bool isLoadingCenters = false;
  bool isBooking = false;
  String? errorMessage;

  // Tracks which tests are selected for a (potentially multi-test)
  // booking - lives here rather than on the list screen's own State
  // since BookLabTestScreen, a separate screen pushed on top, needs to
  // read the same selection.
  final Set<int> selectedTestIds = {};

  void toggleTestSelection(int testId) {
    if (selectedTestIds.contains(testId)) {
      selectedTestIds.remove(testId);
    } else {
      selectedTestIds.add(testId);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedTestIds.clear();
    notifyListeners();
  }

  List<LabTest> get selectedTests => tests.where((t) => selectedTestIds.contains(t.id)).toList();

  Future<void> loadTests() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([_service.getLabTests(), _service.getBlockedDates()]);
      tests = results[0] as List<LabTest>;
      blockedDates = results[1] as List<DateTime>;
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isDateBlocked(DateTime date) {
    return blockedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  /// Centers qualifying for this specific test - already filtered
  /// server-side by visit type, so every result is a valid pick.
  Future<List<LabCenter>> loadCentersFor(int labTestId) async {
    isLoadingCenters = true;
    notifyListeners();

    try {
      return await _service.getCenters(labTestId);
    } on ApiException catch (e) {
      errorMessage = e.message;
      return [];
    } finally {
      isLoadingCenters = false;
      notifyListeners();
    }
  }

  /// Centers qualifying for every one of these tests together - the
  /// multi-test equivalent of loadCentersFor() above.
  Future<List<LabCenter>> loadCentersForMultiple(List<int> labTestIds) async {
    isLoadingCenters = true;
    notifyListeners();

    try {
      return await _service.getCentersForMultiple(labTestIds);
    } on ApiException catch (e) {
      errorMessage = e.message;
      return [];
    } finally {
      isLoadingCenters = false;
      notifyListeners();
    }
  }

  /// Always a list of test ids now, even for a single test - one code
  /// path for both, matching the service and backend.
  Future<Order?> book({
    required List<int> labTestIds,
    required int labCenterId,
    required String scheduledDate,
    int? addressId,
  }) async {
    isBooking = true;
    errorMessage = null;
    notifyListeners();

    try {
      final order = await _service.createBooking(
        labTestIds: labTestIds,
        labCenterId: labCenterId,
        scheduledDate: scheduledDate,
        addressId: addressId,
      );
      clearSelection();
      return order;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } finally {
      isBooking = false;
      notifyListeners();
    }
  }
}
