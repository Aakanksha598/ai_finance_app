import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS/macOS
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await _notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Budget alerts
  static Future<void> showBudgetAlert({
    required String budgetName,
    required double currentAmount,
    required double targetAmount,
    required double percentage,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications for budget limits and alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Budget Alert: $budgetName',
      'You\'ve spent ${percentage.toStringAsFixed(1)}% of your budget '
          '(${currentAmount.toStringAsFixed(2)}/${targetAmount.toStringAsFixed(2)})',
      platformDetails,
    );
  }

  // Goal reminders
  static Future<void> showGoalReminder({
    required String goalName,
    required double currentAmount,
    required double targetAmount,
    required int daysRemaining,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'goal_reminders',
      'Goal Reminders',
      channelDescription: 'Notifications for savings goals',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Goal Reminder: $goalName',
      'You have $daysRemaining days left. Progress: '
          '${((currentAmount / targetAmount) * 100).toStringAsFixed(1)}%',
      platformDetails,
    );
  }

  // Price drop alerts
  static Future<void> showPriceDropAlert({
    required String itemName,
    required double oldPrice,
    required double newPrice,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'price_drops',
      'Price Drops',
      channelDescription: 'Notifications for price drops on tracked items',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      'Price Drop Alert!',
      '$itemName price dropped from \$${oldPrice.toStringAsFixed(2)} '
          'to \$${newPrice.toStringAsFixed(2)}',
      platformDetails,
    );
  }

  // Helper for daily scheduling
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Schedule recurring daily reminder notification
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      4,
      'Daily Financial Check-in',
      'Time to review your finances and track your progress!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily financial check-in reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
