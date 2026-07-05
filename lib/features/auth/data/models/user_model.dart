import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.employeeId,
    required super.email,
    required super.role,
    required super.isActive,
    required super.isBlocked,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      employeeId: map['employeeId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'employee',
      isActive: map['isActive'] as bool? ?? true,
      isBlocked: map['isBlocked'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      employeeId: data['employeeId'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'employee',
      isActive: data['isActive'] as bool? ?? true,
      isBlocked: data['isBlocked'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'employeeId': employeeId,
      'email': email,
      'role': role,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
