import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/medicine_reminder.dart';
import '../services/medicine_reminder_service.dart';
import '../services/notification_scheduler.dart';

class MedicineReminderProvider extends ChangeNotifier {
  MedicineReminderProvider(this._service);

  final MedicineReminderService _service;

  List<MedicineReminder> reminders = [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadReminders() async {
    isLoading = true;
    notifyListeners();

    try {
      reminders = await _service.getReminders();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReminder({
    required String medicineName,
    String? dosageNote,
    required List<String> times,
    required String startDate,
    String? endDate,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final reminder = await _service.createReminder(
        medicineName: medicineName,
        dosageNote: dosageNote,
        times: times,
        startDate: startDate,
        endDate: endDate,
      );
      // Scheduling only after the backend confirms the reminder was
      // actually saved - a local notification for a reminder that
      // failed to save server-side would be confusing and unrecoverable
      // (no record to ever show or let the customer stop later).
      await NotificationScheduler.scheduleForReminder(reminder);
      reminders = await _service.getReminders();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> stopReminder(MedicineReminder reminder) async {
    try {
      await _service.stopReminder(reminder.id);
      await NotificationScheduler.cancelForReminder(reminder.id, reminder.times.length);
      reminders = await _service.getReminders();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
