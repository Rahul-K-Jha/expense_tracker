import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showBudgetAlert({
    required String categoryName,
    required double spent,
    required double budget,
  }) async {
    final percentage = ((spent / budget) * 100).toStringAsFixed(0);

    await _plugin.show(
      categoryName.hashCode,
      'Budget Alert: $categoryName',
      'You\'ve spent $percentage% of your \u20B9${budget.toStringAsFixed(0)} budget (\u20B9${spent.toStringAsFixed(0)})',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Notifications when you approach or exceed budget limits',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showBudgetExceeded({
    required String categoryName,
    required double spent,
    required double budget,
  }) async {
    final over = spent - budget;

    await _plugin.show(
      'exceeded_$categoryName'.hashCode,
      'Over Budget: $categoryName',
      'You\'ve exceeded your budget by \u20B9${over.toStringAsFixed(0)}!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Notifications when you approach or exceed budget limits',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }

  Future<void> showDailyReminder() async {
    await _plugin.show(
      0,
      'Expense Reminder',
      'Don\'t forget to log your expenses for today!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily reminders to log expenses',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  Future<void> showRecurringExpenseReminder({
    required String description,
    required double amount,
  }) async {
    await _plugin.show(
      description.hashCode,
      'Recurring Expense Due',
      '$description - \u20B9${amount.toStringAsFixed(2)}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_expenses',
          'Recurring Expenses',
          channelDescription: 'Reminders for recurring/subscription expenses',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
