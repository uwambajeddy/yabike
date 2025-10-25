class Goal {
  final String id;
  final String name;
  final String category;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String? description;

  Goal({
    required this.id,
    required this.name,
    required this.category,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.createdAt,
    this.description,
  });

  // Calculate percentage saved
  double get percentageSaved {
    if (targetAmount == 0) return 0;
    return (savedAmount / targetAmount * 100).clamp(0, 100);
  }

  // Days remaining until target date
  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  // Check if goal is achieved
  bool get isAchieved => savedAmount >= targetAmount;

  // Check if goal is overdue
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isAchieved;

  // Amount remaining to save
  double get remainingAmount {
    final remaining = targetAmount - savedAmount;
    return remaining > 0 ? remaining : 0;
  }

  // Daily savings needed
  double get dailySavingsNeeded {
    if (daysRemaining == 0 || remainingAmount == 0) return 0;
    return remainingAmount / daysRemaining;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
    );
  }

  Goal copyWith({
    String? id,
    String? name,
    String? category,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    String? description,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }
}
