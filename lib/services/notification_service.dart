import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> schedulePrayerNotifications(
      Map<String, String> prayerTimes) async {
    await _notifications.cancelAll();

    final now = DateTime.now();
    final format = DateFormat('hh:mm a');

    prayerTimes.forEach((prayer, timeStr) async {
      if (timeStr == "--:--") return;

      final time = format.parse(timeStr);

      var prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      final scheduledDate = tz.TZDateTime.from(prayerDateTime, tz.local);

      await _notifications.zonedSchedule(
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        prayerTimes.keys.toList().indexOf(prayer),
        'Prayer Time',
        'Time for $prayer',
        scheduledDate,
        NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_times',
              'Prayer Times',
              channelDescription: 'Notifications for prayer times',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              styleInformation: const BigTextStyleInformation(''),
              when: scheduledDate.millisecondsSinceEpoch,
              usesChronometer: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            )),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    });
  }
}
