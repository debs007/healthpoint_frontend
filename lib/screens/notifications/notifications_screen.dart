import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../models/app_notification.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _tabs = <String, String?>{
    'All': null,
    'Orders': 'order',
    'Medicine & Health': 'health',
    'Offers': 'offer',
    'Alerts': 'alert',
  };

  String _activeTab = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => TextButton(
              onPressed: provider.unreadCount > 0 ? () => provider.markAllRead() : null,
              child: const Text('Mark all read'),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadNotifications);
          }

          final type = _tabs[_activeTab];
          final filtered = type == null
              ? provider.notifications
              : provider.notifications.where((n) => n.type == type).toList();

          return Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _tabs.keys.map((tab) {
                    final selected = tab == _activeTab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: selected,
                        onSelected: (_) => setState(() => _activeTab = tab),
                        selectedColor: AppColors.surfaceTint,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        ),
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text('No notifications here yet.', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : RefreshIndicator(
                        onRefresh: provider.loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _NotificationTile(notification: filtered[i]),
                        ),
                      ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enable Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Get important updates and never miss anything', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Push notifications need Firebase Cloud Messaging setup, which hasn\'t been built yet - in-app notifications above are real')),
                      ),
                      child: const Text('Enable'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  IconData get _icon {
    switch (notification.type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.favorite_border_rounded;
      case 'offer':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: notification.isRead ? null : () => context.read<NotificationProvider>().markRead(notification.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : AppColors.surfaceTint.withValues(alpha: 0.4),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(8)),
              child: Icon(_icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(left: 6, top: 3),
                          decoration: const BoxDecoration(color: AppColors.badgeRed, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(notification.message, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd MMM, hh:mm a').format(notification.createdAt), style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
