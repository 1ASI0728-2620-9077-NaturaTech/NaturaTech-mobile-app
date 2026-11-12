import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _prefKey = 'notifications_enabled';
  static bool _initialized = false;

  static const _channelDetails = AndroidNotificationDetails(
    'task_channel',
    'Tareas de Plantas',
    channelDescription: 'Recordatorios de tareas de cuidado de plantas',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _notificationDetails = NotificationDetails(android: _channelDetails);

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(settings: const InitializationSettings(android: androidSettings));
    _initialized = true;
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    if (!value) await _plugin.cancelAll();
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  static Future<void> showTaskNotification({
    required int taskId,
    required String action,
    required String plantName,
  }) async {
    if (!await isEnabled()) return;

    await _plugin.show(
      id: taskId,
      title: 'Tarea pendiente: $action',
      body: 'Tu planta "$plantName" necesita atencion hoy',
      notificationDetails: _notificationDetails,
    );
  }

  static Future<void> scheduleTaskNotification({
    required int taskId,
    required String action,
    required String plantName,
    required DateTime scheduledDate,
  }) async {
    if (!await isEnabled()) return;

    final scheduledTime = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      8,
      0,
    );

    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: taskId,
      title: 'Tarea pendiente: $action',
      body: 'Tu planta "$plantName" necesita atencion hoy',
      scheduledDate: scheduledTime,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int taskId) async {
    await _plugin.cancel(id: taskId);
  }
}
