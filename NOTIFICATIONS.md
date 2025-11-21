# Notification System Implementation

## Overview
Comprehensive local notification system for YaBike app covering budget alerts, transaction monitoring, backup status, and financial insights.

## Features Implemented

### 1. Budget Alerts ✅
- **80% Warning**: Notifies when spending reaches 80% of budget
- **Budget Exceeded**: Alert when budget limit is exceeded
- **Weekly Summary**: Budget performance overview sent weekly
- **Smart Tracking**: Each budget only notified once per threshold

### 2. Transaction Alerts ✅
- **New SMS Imports**: Silent notification when SMS transactions detected
- **Daily Summary**: Optional end-of-day transaction recap
- **Uncategorized Reminder**: Prompts every 3 days to categorize transactions
- **Unusual Spending**: Alerts when spending is 2x average in a category

### 3. Backup Alerts ✅
- **Success Notification**: Confirms successful backup to Google Drive
- **Failure Alert**: High-priority alert if backup fails
- **Manual Reminder**: Weekly reminder for users on manual backup mode

### 4. Financial Insights ✅
- **Monthly Reports**: Spending comparison with previous month
- **Weekly Insights**: Top expense category analysis
- **Savings Celebrations**: Achievement notifications for meeting savings targets

## Files Created/Modified

### New Files:
1. `lib/data/services/notification_service.dart` - Main notification service
2. `lib/features/settings/screens/notification_settings_screen.dart` - User preferences UI

### Modified Files:
1. `lib/main.dart` - Initialize notification service on app startup
2. `lib/data/services/backup_service.dart` - Added backup notifications
3. `lib/data/services/sms_rescan_service.dart` - Added SMS import notifications
4. `lib/features/budget/viewmodels/budget_viewmodel.dart` - Budget alert checks
5. `lib/features/settings/screens/settings_screen.dart` - Added notifications menu item
6. `lib/core/routes/app_routes.dart` - Added notification settings route

## Notification Channels

| Channel ID | Purpose | Importance |
|------------|---------|------------|
| budget_alerts | Budget warnings and exceeded alerts | High |
| transaction_alerts | Transaction updates and reminders | Low/Default |
| backup_alerts | Backup status notifications | Low/High |
| financial_insights | Weekly/Monthly reports | Default |

## User Settings

Users can control notifications via Settings > Notifications:

- ✅ Budget Alerts
- ✅ Transaction Alerts
- ✅ Daily Summary
- ✅ Backup Status
- ✅ Weekly Insights
- ✅ Monthly Reports

Settings are stored in Hive `settings` box with keys prefixed `notif_*`.

## Notification Timing Logic

### Smart Throttling:
- **Budget Alerts**: Once per threshold (80%, 100%)
- **Weekly Summary**: Max once every 7 days
- **Monthly Reports**: Once per calendar month
- **Uncategorized Reminder**: Every 3 days
- **Backup Reminder**: Weekly for manual mode

### Timestamps Stored:
- `last_budget_summary` - Last weekly budget summary
- `last_transaction_summary` - Last daily transaction summary
- `last_uncategorized_reminder` - Last uncategorized reminder
- `last_backup_reminder` - Last backup reminder
- `last_monthly_report` - Last monthly financial report (yyyy-MM format)
- `last_weekly_insight` - Last weekly spending insight
- `notified_budgets` - Map of budget IDs to threshold levels

## Integration Points

### Budget ViewModel
```dart
await NotificationService().checkBudgetAlert(budget, spent);
```

### SMS Rescan Service
```dart
await NotificationService().notifyNewTransactions(newTransactions.length);
```

### Backup Service
```dart
await NotificationService().notifyBackupSuccess();
await NotificationService().notifyBackupFailure(error);
```

## Permission Handling

- Automatically requests notification permissions on initialization
- Supports both Android and iOS notification systems
- Falls back gracefully if permissions denied

## Future Enhancements (Not Implemented)

1. Bill Payment Reminders (requires recurring expense feature)
2. Savings Goals Progress (requires goals feature)
3. Navigation from notification tap (payload handling stub exists)
4. Custom notification sounds
5. Rich notifications with action buttons

## Testing Checklist

- [ ] Budget 80% warning appears
- [ ] Budget exceeded alert shows
- [ ] SMS import notification works
- [ ] Backup success/failure notifications
- [ ] Weekly/monthly summaries trigger
- [ ] Settings screen toggles work
- [ ] Notifications respect user preferences
- [ ] Throttling prevents spam

## Notes

- All notifications use app icon as notification icon
- Colors match app theme (green for success, red for alerts)
- Notification service is singleton pattern
- All notification logic is centralized in one service
