import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/app_notification.dart';

class NotificationService {
  NotificationService(this._client);

  final ApiClient _client;

  Future<({List<AppNotification> notifications, int unreadCount})> getNotifications() async {
    final response = await _client.get(ApiEndpoints.notifications);
    final data = response['data'] as List<dynamic>? ?? [];
    return (
      notifications: data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList(),
      unreadCount: response['unread_count'] as int? ?? 0,
    );
  }

  Future<void> markRead(int id) async {
    await _client.post(ApiEndpoints.markNotificationRead(id));
  }

  Future<void> markAllRead() async {
    await _client.post(ApiEndpoints.markAllNotificationsRead);
  }
}
