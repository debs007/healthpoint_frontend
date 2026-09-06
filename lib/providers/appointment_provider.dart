import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/appointment_booking.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../models/order.dart';
import '../services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider(this._service);

  final AppointmentService _service;

  List<Department> departments = [];
  List<Doctor> doctors = [];
  List<AppointmentBooking> myBookings = [];
  bool isLoading = false;
  bool isLoadingBookings = false;
  bool isBooking = false;
  String? errorMessage;

  Future<void> loadDepartments() async {
    if (departments.isNotEmpty) return;
    try {
      departments = await _service.getDepartments();
      notifyListeners();
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> loadDoctors({int? departmentId}) async {
    isLoading = true;
    notifyListeners();

    try {
      doctors = await _service.getDoctors(departmentId: departmentId);
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Doctor?> loadDoctor(int id) async {
    try {
      return await _service.getDoctor(id);
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMyBookings() async {
    isLoadingBookings = true;
    notifyListeners();

    try {
      myBookings = await _service.getMyBookings();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingBookings = false;
      notifyListeners();
    }
  }

  Future<Order?> book({required int doctorId, required int affiliationId, required String scheduledDate}) async {
    isBooking = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _service.bookAppointment(doctorId: doctorId, affiliationId: affiliationId, scheduledDate: scheduledDate);
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } finally {
      isBooking = false;
      notifyListeners();
    }
  }
}
