import 'package:uuid/uuid.dart';

/// Notification history model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'budget', 'transaction', 'backup', 'insight'
  final String? payload;
  final DateTime timestamp;
  final bool isRead;
  final String? icon; // emoji or icon name

  NotificationItem({
    String? id,
    required this.title,
    required this.message,
    required this.type,
    this.payload,
    DateTime? timestamp,
    this.isRead = false,
    this.icon,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // From JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      payload: json['payload'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      icon: json['icon'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'icon': icon,
    };
  }

  // Copy with
  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? payload,
    DateTime? timestamp,
    bool? isRead,
    String? icon,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
    );
  }

  // Get icon by type
  String getIcon() {
    if (icon != null) return icon!;
    
    switch (type) {
      case 'budget':
        if (title.contains('Exceeded')) return '🚨';
        if (title.contains('Alert')) return '⚠️';
        return '📊';
      case 'transaction':
        if (title.contains('Unusual')) return '⚡';
        return '💰';
      case 'backup':
        if (title.contains('Failed')) return '❌';
        return '☁️';
      case 'insight':
        if (title.contains('Great')) return '🎉';
        return '💡';
      default:
        return '🔔';
    }
  }
}
