import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'tempori_expiry_channel',
    'Pengingat Kedaluwarsa',
    channelDescription: 'Notifikasi pengingat tanggal kedaluwarsa barang',
    importance: Importance.max,
    priority: Priority.high,
  );

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(settings);
  }

  static Future<bool?> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    return android?.requestNotificationsPermission();
  }

  static int _notificationId(String itemId) {
    // Membuat ID angka yang konsisten dari item_id.
    var hash = 0;
    for (final unit in itemId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  static Future<void> scheduleExpiryReminder({
    required String itemId,
    required String itemName,
    required DateTime expiryDate,
    required int reminderDays,
  }) async {

    await cancelReminder(itemId);

    if (![1, 3, 7].contains(reminderDays)) return;

    final reminderDate = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    ).subtract(Duration(days: reminderDays));

    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
    );

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _plugin.zonedSchedule(
      _notificationId(itemId),
      'Waktunya cek barangmu!',
      '$itemName akan kedaluwarsa dalam $reminderDays hari. Yuk, segera cek barangmu!',
      scheduledDate,
      const NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: itemId,
    );
  }

  static Future<void> cancelReminder(String itemId) async {
    await _plugin.cancel(_notificationId(itemId));
  }

  static Future<void> showTestNotification() async {
    await _plugin.show(
      999999,
      'Tempori berhasil!',
      'Notifikasi Tempori sudah aktif di perangkatmu.',
      const NotificationDetails(android: _androidDetails),
    );
  }
}