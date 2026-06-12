import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static int notificationId(String entityId) => entityId.hashCode;

  /// Reset initialized flag (for testing).
  static void reset() {
    _initialized = false;
  }

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
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
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    const androidDetails = AndroidNotificationDetails(
      'journey_joy_channel',
      'Journey Joy',
      channelDescription: 'Trip and activity reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, title, body, details);
  }

  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) return;
    if (scheduledDate.isBefore(DateTime.now())) return;
    final location = tz.local;
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, location);
    const androidDetails = AndroidNotificationDetails(
      'journey_joy_channel',
      'Journey Joy',
      channelDescription: 'Trip and activity reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleTripReminder(
      String tripId, String tripName, DateTime startDate) async {
    if (!_initialized) return;
    final reminderDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day - 1,
      9,
      0,
    );
    await schedule(
      id: notificationId(tripId),
      title: 'Trip Tomorrow!',
      body: 'Your trip "$tripName" starts tomorrow. Get ready!',
      scheduledDate: reminderDate,
    );
  }

  static Future<void> cancelTripReminder(String tripId) async {
    if (!_initialized) return;
    await _plugin.cancel(notificationId(tripId));
  }

  static Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}
