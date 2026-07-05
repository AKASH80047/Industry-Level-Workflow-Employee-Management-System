import 'package:flutter/foundation.dart';

@immutable
class UserEntity {
  final String uid;
  final String employeeId;
  final String email;
  final String role; // 'admin' | 'manager' | 'employee'
  final bool isActive;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.uid,
    required this.employeeId,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    String? uid,
    String? employeeId,
    String? email,
    String? role,
    bool? isActive,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
