import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late Box _settingsBox;
  
  bool _budgetAlerts = true;
  bool _transactionAlerts = true;
  bool _backupAlerts = true;
  bool _weeklyInsights = true;
  bool _monthlyReports = true;
  bool _dailySummary = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = Hive.box('settings');
    setState(() {
      _budgetAlerts = _settingsBox.get('notif_budget_alerts', defaultValue: true);
      _transactionAlerts = _settingsBox.get('notif_transaction_alerts', defaultValue: true);
      _backupAlerts = _settingsBox.get('notif_backup_alerts', defaultValue: true);
      _weeklyInsights = _settingsBox.get('notif_weekly_insights', defaultValue: true);
      _monthlyReports = _settingsBox.get('notif_monthly_reports', defaultValue: true);
      _dailySummary = _settingsBox.get('notif_daily_summary', defaultValue: false);
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    await _settingsBox.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Budget Alerts Section
          _buildSectionHeader('Budget Alerts'),
          const SizedBox(height: 12),
          _buildSettingTile(
            title: 'Budget Warnings',
            subtitle: 'Get notified when you reach 80% of your budget',
            value: _budgetAlerts,
            onChanged: (value) {
              setState(() => _budgetAlerts = value);
              _saveSetting('notif_budget_alerts', value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Transaction Alerts Section
          _buildSectionHeader('Transaction Alerts'),
          const SizedBox(height: 12),
          _buildSettingTile(
            title: 'New Transactions',
            subtitle: 'Notify when SMS transactions are imported',
            value: _transactionAlerts,
            onChanged: (value) {
              setState(() => _transactionAlerts = value);
              _saveSetting('notif_transaction_alerts', value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            title: 'Daily Summary',
            subtitle: 'Get a daily summary of your transactions',
            value: _dailySummary,
            onChanged: (value) {
              setState(() => _dailySummary = value);
              _saveSetting('notif_daily_summary', value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Backup Alerts Section
          _buildSectionHeader('Backup Alerts'),
          const SizedBox(height: 12),
          _buildSettingTile(
            title: 'Backup Status',
            subtitle: 'Get notified about backup success or failures',
            value: _backupAlerts,
            onChanged: (value) {
              setState(() => _backupAlerts = value);
              _saveSetting('notif_backup_alerts', value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Financial Insights Section
          _buildSectionHeader('Financial Insights'),
          const SizedBox(height: 12),
          _buildSettingTile(
            title: 'Weekly Insights',
            subtitle: 'Receive weekly spending insights and tips',
            value: _weeklyInsights,
            onChanged: (value) {
              setState(() => _weeklyInsights = value);
              _saveSetting('notif_weekly_insights', value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            title: 'Monthly Reports',
            subtitle: 'Get monthly financial reports and comparisons',
            value: _monthlyReports,
            onChanged: (value) {
              setState(() => _monthlyReports = value);
              _saveSetting('notif_monthly_reports', value);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications help you stay on top of your finances. You can always change these settings later.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
