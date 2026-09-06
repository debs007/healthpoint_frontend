import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine_reminder.dart';

/// Deliberately schedules one *recurring daily* notification per
/// time-of-day in a reminder (via matchDateTimeComponents: time), not
/// one notification per individual day of the course. iOS caps an app
/// at 64 total pending local notifications - scheduling every occurrence
/// of even a single 30-day, 3-times-daily course would already use 90,
/// before counting any other active reminder at all. The trade-off:
/// this doesn't automatically stop on end_date - see cancelForReminder,
/// which the app calls explicitly when a reminder is stopped or its
/// course naturally ends, rather than relying on fragile background
/// checks to catch the date on the OS's behalf.
class NotificationScheduler {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// One notification id per (reminder, time-of-day) pair, deterministic
  /// from the reminder's own id - lets cancelForReminder recompute every
  /// id it needs to cancel without having to separately track which ids
  /// were used for which reminder.
  static int _notificationId(int reminderId, int timeIndex) => reminderId * 100 + timeIndex;

  static Future<void> scheduleForReminder(MedicineReminder reminder) async {
    await initialize();

    for (var i = 0; i < reminder.times.length; i++) {
      final parts = reminder.times[i].split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _notificationId(reminder.id, i),
        'Time for your medicine',
        reminder.dosageNote != null && reminder.dosageNote!.isNotEmpty
            ? '${reminder.medicineName} - ${reminder.dosageNote}'
            : reminder.medicineName,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminders',
            'Medicine Reminders',
            channelDescription: 'Reminders to take your medicine on schedule',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime 
      );
    }
  }

  /// Cancels every time-slot for this reminder - recomputes each id the
  /// same deterministic way scheduleForReminder assigned them, rather
  /// than needing a separately stored list of what was scheduled.
  static Future<void> cancelForReminder(int reminderId, int timeSlotCount) async {
    for (var i = 0; i < timeSlotCount; i++) {
      await _plugin.cancel(_notificationId(reminderId, i));
    }
  }
}
