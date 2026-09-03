import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._notificationService);

  final NotificationService _notificationService;

  List<AppNotification> notifications = [];
  int unreadCount = 0;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _notificationService.getNotifications();
      notifications = result.notifications;
      unreadCount = result.unreadCount;
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(int id) async {
    await _notificationService.markRead(id);
    await loadNotifications();
  }

  Future<void> markAllRead() async {
    await _notificationService.markAllRead();
    await loadNotifications();
  }
}
