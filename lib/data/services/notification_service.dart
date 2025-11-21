import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification channels
  static const String _budgetChannelId = 'budget_alerts';
  static const String _transactionChannelId = 'transaction_alerts';
  static const String _backupChannelId = 'backup_alerts';
  static const String _insightsChannelId = 'financial_insights';

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
    debugPrint('✅ Notification service initialized');
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }

  // ==================== BUDGET ALERTS ====================

  /// Check budget and send alert if needed
  Future<void> checkBudgetAlert(Budget budget, double currentSpending) async {
    if (!_initialized) await initialize();

    final percentage = (currentSpending / budget.amount) * 100;
    final settingsBox = Hive.box('settings');
    final notifiedBudgets = settingsBox.get('notified_budgets', defaultValue: <String, int>{}) as Map;
    final lastNotified = notifiedBudgets[budget.id] ?? 0;

    // 80% warning (only once)
    if (percentage >= 80 && percentage < 100 && lastNotified < 80) {
      await _showBudgetWarning(budget, currentSpending, percentage);
      notifiedBudgets[budget.id] = 80;
      await settingsBox.put('notified_budgets', notifiedBudgets);
    }

    // 100% exceeded (only once)
    if (percentage >= 100 && lastNotified < 100) {
      await _showBudgetExceeded(budget, currentSpending, percentage);
      notifiedBudgets[budget.id] = 100;
      await settingsBox.put('notified_budgets', notifiedBudgets);
    }
  }

  Future<void> _showBudgetWarning(Budget budget, double spending, double percentage) async {
    final androidDetails = AndroidNotificationDetails(
      _budgetChannelId,
      'Budget Alerts',
      channelDescription: 'Notifications for budget warnings and exceeded limits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      budget.id.hashCode % 100000,
      '⚠️ Budget Alert: ${budget.category}',
      'You\'ve spent ${percentage.toStringAsFixed(0)}% of your ${budget.category} budget. RWF ${_formatAmount(budget.amount - spending)} remaining.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'budget:${budget.id}',
    );
  }

  Future<void> _showBudgetExceeded(Budget budget, double spending, double percentage) async {
    final androidDetails = AndroidNotificationDetails(
      _budgetChannelId,
      'Budget Alerts',
      channelDescription: 'Notifications for budget warnings and exceeded limits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFEF5350),
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      budget.id.hashCode % 100000 + 1,
      '🚨 Budget Exceeded: ${budget.category}',
      'You\'ve exceeded your ${budget.category} budget by RWF ${_formatAmount(spending - budget.amount)}!',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'budget:${budget.id}',
    );
  }

  /// Send weekly budget summary
  Future<void> sendWeeklyBudgetSummary(List<Budget> budgets, Map<String, double> spending) async {
    if (!_initialized) await initialize();

    final settingsBox = Hive.box('settings');
    final lastSummary = settingsBox.get('last_budget_summary', defaultValue: 0) as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final weekInMs = 7 * 24 * 60 * 60 * 1000;

    // Only send once per week
    if (now - lastSummary < weekInMs) return;

    int onTrack = 0;
    int nearLimit = 0;
    int exceeded = 0;

    for (final budget in budgets) {
      final spent = spending[budget.category] ?? 0;
      final percentage = (spent / budget.amount) * 100;

      if (percentage >= 100) {
        exceeded++;
      } else if (percentage >= 80) {
        nearLimit++;
      } else {
        onTrack++;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      _budgetChannelId,
      'Budget Alerts',
      channelDescription: 'Notifications for budget warnings and exceeded limits',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      1001,
      '📊 Weekly Budget Summary',
      '$onTrack budgets on track • $nearLimit near limit • $exceeded exceeded',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'budgets',
    );

    await settingsBox.put('last_budget_summary', now);
  }

  // ==================== TRANSACTION ALERTS ====================

  /// Notify when new SMS transactions are imported
  Future<void> notifyNewTransactions(int count) async {
    if (!_initialized) await initialize();
    if (count == 0) return;

    final androidDetails = AndroidNotificationDetails(
      _transactionChannelId,
      'Transaction Alerts',
      channelDescription: 'Notifications for new transactions and reminders',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      2001,
      '💰 New Transactions',
      '$count new transaction${count > 1 ? 's' : ''} imported from SMS',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'transactions',
    );
  }

  /// Send daily transaction summary
  Future<void> sendDailyTransactionSummary(List<Transaction> todayTransactions) async {
    if (!_initialized) await initialize();
    if (todayTransactions.isEmpty) return;

    final settingsBox = Hive.box('settings');
    final lastSummary = settingsBox.get('last_transaction_summary', defaultValue: '');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Only send once per day
    if (lastSummary == today) return;

    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in todayTransactions) {
      if (tx.type == 'credit') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      _transactionChannelId,
      'Transaction Alerts',
      channelDescription: 'Notifications for new transactions and reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    final currency = todayTransactions.first.currency;
    await _notifications.show(
      2002,
      '📋 Today\'s Activity',
      '${todayTransactions.length} transactions • Income: $currency ${_formatAmount(totalIncome)} • Expenses: $currency ${_formatAmount(totalExpense)}',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'transactions',
    );

    await settingsBox.put('last_transaction_summary', today);
  }

  /// Remind user about uncategorized transactions
  Future<void> remindUncategorizedTransactions(int count) async {
    if (!_initialized) await initialize();
    if (count == 0) return;

    final settingsBox = Hive.box('settings');
    final lastReminder = settingsBox.get('last_uncategorized_reminder', defaultValue: 0) as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final threeDaysInMs = 3 * 24 * 60 * 60 * 1000;

    // Only remind every 3 days
    if (now - lastReminder < threeDaysInMs) return;

    final androidDetails = AndroidNotificationDetails(
      _transactionChannelId,
      'Transaction Alerts',
      channelDescription: 'Notifications for new transactions and reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      2003,
      '📝 Uncategorized Transactions',
      'You have $count transaction${count > 1 ? 's' : ''} without categories. Categorize them for better insights.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'transactions',
    );

    await settingsBox.put('last_uncategorized_reminder', now);
  }

  /// Detect unusual spending pattern
  Future<void> notifyUnusualSpending(String category, double amount, double avgAmount) async {
    if (!_initialized) await initialize();
    if (amount <= avgAmount * 2) return; // Only if 2x average

    final androidDetails = AndroidNotificationDetails(
      _transactionChannelId,
      'Transaction Alerts',
      channelDescription: 'Notifications for new transactions and reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFFA726),
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      2004,
      '⚡ Unusual Spending Detected',
      'Your $category spending is higher than usual. Review your transactions.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'transactions',
    );
  }

  // ==================== BACKUP ALERTS ====================

  /// Notify backup success
  Future<void> notifyBackupSuccess() async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      _backupChannelId,
      'Backup Alerts',
      channelDescription: 'Notifications for backup status',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      3001,
      '☁️ Backup Complete',
      'Your data has been backed up successfully to Google Drive',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'backup',
    );
  }

  /// Notify backup failure
  Future<void> notifyBackupFailure(String error) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      _backupChannelId,
      'Backup Alerts',
      channelDescription: 'Notifications for backup status',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFEF5350),
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      3002,
      '❌ Backup Failed',
      'Failed to backup your data. Please check your internet connection.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'backup',
    );
  }

  /// Remind user to backup (for manual mode)
  Future<void> remindBackup() async {
    if (!_initialized) await initialize();

    final settingsBox = Hive.box('settings');
    final lastReminder = settingsBox.get('last_backup_reminder', defaultValue: 0) as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final weekInMs = 7 * 24 * 60 * 60 * 1000;

    // Only remind weekly
    if (now - lastReminder < weekInMs) return;

    final androidDetails = AndroidNotificationDetails(
      _backupChannelId,
      'Backup Alerts',
      channelDescription: 'Notifications for backup status',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      3003,
      '💾 Time to Backup',
      'It\'s been a while since your last backup. Backup your data to keep it safe.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'backup',
    );

    await settingsBox.put('last_backup_reminder', now);
  }

  // ==================== FINANCIAL INSIGHTS ====================

  /// Send monthly spending report
  Future<void> sendMonthlyReport(double totalSpent, double lastMonthSpent, double savings) async {
    if (!_initialized) await initialize();

    final settingsBox = Hive.box('settings');
    final lastReport = settingsBox.get('last_monthly_report', defaultValue: '');
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

    // Only send once per month
    if (lastReport == currentMonth) return;

    final change = totalSpent - lastMonthSpent;
    final percentChange = lastMonthSpent > 0 ? (change / lastMonthSpent * 100).abs() : 0;
    final improved = change <= 0;

    final androidDetails = AndroidNotificationDetails(
      _insightsChannelId,
      'Financial Insights',
      channelDescription: 'Monthly reports and financial insights',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: improved ? const Color(0xFF66BB6A) : const Color(0xFFFFA726),
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      4001,
      '📈 Monthly Financial Report',
      improved
          ? '${percentChange.toStringAsFixed(0)}% less spending this month! You saved ${_formatAmount(savings)}.'
          : '${percentChange.toStringAsFixed(0)}% more spending this month. Total: ${_formatAmount(totalSpent)}',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'insights',
    );

    await settingsBox.put('last_monthly_report', currentMonth);
  }

  /// Send weekly insights
  Future<void> sendWeeklyInsights(String topCategory, double categorySpending, double totalSpending) async {
    if (!_initialized) await initialize();

    final settingsBox = Hive.box('settings');
    final lastInsight = settingsBox.get('last_weekly_insight', defaultValue: 0) as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final weekInMs = 7 * 24 * 60 * 60 * 1000;

    // Only send once per week
    if (now - lastInsight < weekInMs) return;

    final percentage = (categorySpending / totalSpending * 100).toStringAsFixed(0);

    final androidDetails = AndroidNotificationDetails(
      _insightsChannelId,
      'Financial Insights',
      channelDescription: 'Monthly reports and financial insights',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      4002,
      '💡 Weekly Spending Insight',
      '$topCategory is your top expense category at $percentage% of total spending this week.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'insights',
    );

    await settingsBox.put('last_weekly_insight', now);
  }

  /// Celebrate savings achievement
  Future<void> celebrateSavings(double savedAmount, double target) async {
    if (!_initialized) await initialize();

    final percentage = (savedAmount / target * 100).toStringAsFixed(0);

    final androidDetails = AndroidNotificationDetails(
      _insightsChannelId,
      'Financial Insights',
      channelDescription: 'Monthly reports and financial insights',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF66BB6A),
    );

    final iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      4003,
      '🎉 Great Job!',
      'You\'ve saved $percentage% more than your target this month! Keep it up!',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'insights',
    );
  }

  // ==================== UTILITY METHODS ====================

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
