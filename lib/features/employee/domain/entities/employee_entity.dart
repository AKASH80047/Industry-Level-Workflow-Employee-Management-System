import 'package:flutter/foundation.dart';

@immutable
class EmployeeEntity {
  final String uid;
  final String employeeId;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePhotoUrl;
  final DateTime joiningDate;
  final String departmentId;
  final String designationId;
  final String? managerId;
  final String shiftId;
  final String officeId;
  final String employmentType; // 'full_time' | 'part_time' | 'intern' | 'contract'
  final String? deviceId;
  final String? deviceModel;
  final String? deviceOS;
  final DateTime? deviceBoundAt;
  final String? fcmToken;
  final double basicSalary;
  final double? allowance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeEntity({
    required this.uid,
    required this.employeeId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
    required this.joiningDate,
    required this.departmentId,
    required this.designationId,
    this.managerId,
    required this.shiftId,
    required this.officeId,
    required this.employmentType,
    this.deviceId,
    this.deviceModel,
    this.deviceOS,
    this.deviceBoundAt,
    this.fcmToken,
    required this.basicSalary,
    this.allowance,
    required this.createdAt,
    required this.updatedAt,
  });

  EmployeeEntity copyWith({
    String? uid,
    String? employeeId,
    String? fullName,
    String? email,
    String? phone,
    String? profilePhotoUrl,
    DateTime? joiningDate,
    String? departmentId,
    String? designationId,
    String? managerId,
    String? shiftId,
    String? officeId,
    String? employmentType,
    String? deviceId,
    String? deviceModel,
    String? deviceOS,
    DateTime? deviceBoundAt,
    String? fcmToken,
    double? basicSalary,
    double? allowance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeEntity(
      uid: uid ?? this.uid,
      employeeId: employeeId ?? this.employeeId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      joiningDate: joiningDate ?? this.joiningDate,
      departmentId: departmentId ?? this.departmentId,
      designationId: designationId ?? this.designationId,
      managerId: managerId ?? this.managerId,
      shiftId: shiftId ?? this.shiftId,
      officeId: officeId ?? this.officeId,
      employmentType: employmentType ?? this.employmentType,
      deviceId: deviceId ?? this.deviceId,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceOS: deviceOS ?? this.deviceOS,
      deviceBoundAt: deviceBoundAt ?? this.deviceBoundAt,
      fcmToken: fcmToken ?? this.fcmToken,
      basicSalary: basicSalary ?? this.basicSalary,
      allowance: allowance ?? this.allowance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
