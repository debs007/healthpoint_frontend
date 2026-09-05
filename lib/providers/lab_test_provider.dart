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

  Future<Order?> book({
    required int labTestId,
    required int labCenterId,
    required String scheduledDate,
    int? addressId,
  }) async {
    isBooking = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _service.createBooking(
        labTestId: labTestId,
        labCenterId: labCenterId,
        scheduledDate: scheduledDate,
        addressId: addressId,
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } finally {
      isBooking = false;
      notifyListeners();
    }
  }
}
