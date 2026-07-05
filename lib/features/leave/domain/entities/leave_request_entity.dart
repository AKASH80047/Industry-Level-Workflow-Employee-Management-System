import 'package:flutter/foundation.dart';

@immutable
class LeaveRequestEntity {
  final String id;
  final String employeeId;
  final String managerId;
  final String leaveType; // 'casual' | 'sick' | 'paid' | 'unpaid' | 'half_day'
  final DateTime startDate;
  final DateTime endDate;
  final double totalDays;
  final String reason;
  final String? attachmentUrl;
  final String status; // 'pending' | 'approved' | 'rejected' | 'cancelled'
  final String? rejectionReason;
  final String? approvedBy;
  final DateTime? actionedAt;
  final DateTime createdAt;

  const LeaveRequestEntity({
    required this.id,
    required this.employeeId,
    required this.managerId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    this.rejectionReason,
    this.approvedBy,
    this.actionedAt,
    required this.createdAt,
  });

  LeaveRequestEntity copyWith({
    String? id,
    String? employeeId,
    String? managerId,
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    double? totalDays,
    String? reason,
    String? attachmentUrl,
    String? status,
    String? rejectionReason,
    String? approvedBy,
    DateTime? actionedAt,
    DateTime? createdAt,
  }) {
    return LeaveRequestEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      managerId: managerId ?? this.managerId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      actionedAt: actionedAt ?? this.actionedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
