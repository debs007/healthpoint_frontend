import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/prescription.dart';
import '../services/prescription_service.dart';

class PrescriptionProvider extends ChangeNotifier {
  PrescriptionProvider(this._prescriptionService);

  final PrescriptionService _prescriptionService;

  List<Prescription> prescriptions = [];
  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;

  Future<void> loadPrescriptions() async {
    isLoading = true;
    notifyListeners();

    try {
      prescriptions = await _prescriptionService.getPrescriptions();
      prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upload(String filePath) async {
    isUploading = true;
    notifyListeners();

    try {
      await _prescriptionService.upload(filePath);
      await loadPrescriptions();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }
}
