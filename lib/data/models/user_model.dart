import 'package:uuid/uuid.dart';

/// User data model
class User {
  final String id;
  final String name;
  final String? email;
  final String? profileImage;
  final bool useBiometric;
  final String pinHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    String? id,
    required this.name,
    this.email,
    this.profileImage,
    this.useBiometric = false,
    required this.pinHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      useBiometric: json['useBiometric'] as bool? ?? false,
      pinHash: json['pinHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'useBiometric': useBiometric,
      'pinHash': pinHash,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    bool? useBiometric,
    String? pinHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      useBiometric: useBiometric ?? this.useBiometric,
      pinHash: pinHash ?? this.pinHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
