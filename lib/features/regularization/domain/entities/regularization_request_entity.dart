import 'package:flutter/foundation.dart';

@immutable
class RegularizationRequestEntity {
  final String id;
  final String attendanceId;
  final String employeeId;
  final String managerId;
  final String dateKey;
  final String issueType; // 'forgot_check_in' | 'forgot_check_out' | 'wrong_time' | 'gps_failure' | 'official_work'
  final DateTime? requestedCheckIn;
  final DateTime? requestedCheckOut;
  final String reason;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionReason;
  final DateTime? actionedAt;
  final DateTime createdAt;

  const RegularizationRequestEntity({
    required this.id,
    required this.attendanceId,
    required this.employeeId,
    required this.managerId,
    required this.dateKey,
    required this.issueType,
    this.requestedCheckIn,
    this.requestedCheckOut,
    required this.reason,
    required this.status,
    this.rejectionReason,
    this.actionedAt,
    required this.createdAt,
  });

  RegularizationRequestEntity copyWith({
    String? id,
    String? attendanceId,
    String? employeeId,
    String? managerId,
    String? dateKey,
    String? issueType,
    DateTime? requestedCheckIn,
    DateTime? requestedCheckOut,
    String? reason,
    String? status,
    String? rejectionReason,
    DateTime? actionedAt,
    DateTime? createdAt,
  }) {
    return RegularizationRequestEntity(
      id: id ?? this.id,
      attendanceId: attendanceId ?? this.attendanceId,
      employeeId: employeeId ?? this.employeeId,
      managerId: managerId ?? this.managerId,
      dateKey: dateKey ?? this.dateKey,
      issueType: issueType ?? this.issueType,
      requestedCheckIn: requestedCheckIn ?? this.requestedCheckIn,
      requestedCheckOut: requestedCheckOut ?? this.requestedCheckOut,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      actionedAt: actionedAt ?? this.actionedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
