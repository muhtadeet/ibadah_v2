import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Top-level callback function for handling background notification responses
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  final Logger logger = Logger();
  logger.i('Notification clicked: ${response.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final Logger logger = Logger();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    logger.i('Timezone initialized to Asia/Dhaka');

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logger.i('Notification clicked: ${response.payload}');
      },
    );
    await _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;
  
  if (status.isDenied || status.isPermanentlyDenied) {
    final permissionStatus = await Permission.notification.request();
    if (permissionStatus.isGranted) {
      logger.i("Notification permission granted");
    } else {
      logger.w("Notification permission denied");
    }
  } else if (status.isGranted) {
    logger.i("Notification permission already granted");
  } else {
    logger.w("Unable to determine notification permission status");
  }
}


  Future<void> schedulePrayerNotifications(
      Map<String, String> prayerTimes) async {
    try {
      await _notifications.cancelAll();
      logger.i('Previous notifications cancelled');

      final now = DateTime.now();
      final format = DateFormat.jm();

      for (var entry in prayerTimes.entries) {
        if (entry.key == 'location' || entry.value == "" || entry.value == "--:--") continue;

        try {
          final time = format.parse(entry.value);
          var scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );

          // If the prayer time has already passed today, schedule for tomorrow
          if (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(const Duration(days: 1));
          }

          final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

          final String prayerName = entry.key.substring(0, 1).toUpperCase() +
              entry.key.substring(1).toLowerCase();

          await _notifications.zonedSchedule(
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            entry.key.hashCode,
            'Time for $prayerName',
            'It\'s time for $prayerName prayer (${entry.value})',
            scheduledDate,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'prayer_times_${entry.key.toLowerCase()}',
                '$prayerName Prayer Time',
                channelDescription: 'Notifications for $prayerName prayer time',
                importance: Importance.max,
                priority: Priority.high,
                enableLights: true,
                enableVibration: true,
                icon: '@mipmap/ic_launcher',
                channelShowBadge: true,
                visibility: NotificationVisibility.public,
                playSound: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );

          logger.i(
              'Scheduled $prayerName notification for ${format.format(scheduledTime)}');
        } catch (e) {
          logger.e('Error scheduling ${entry.key} notification: $e');
        }
      }
    } catch (e) {
      logger.e('Error in schedulePrayerNotifications: $e');
    }
  }

  Future<void> testNotification() async {
    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel_id',
          'Test Channel',
          channelDescription: 'Test Channel Description',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
