import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leave_request_entity.dart';

class LeaveRequestModel extends LeaveRequestEntity {
  const LeaveRequestModel({
    required super.id,
    required super.employeeId,
    required super.managerId,
    required super.leaveType,
    required super.startDate,
    required super.endDate,
    required super.totalDays,
    required super.reason,
    super.attachmentUrl,
    required super.status,
    super.rejectionReason,
    super.approvedBy,
    super.actionedAt,
    required super.createdAt,
  });

  factory LeaveRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return LeaveRequestModel(
      id: docId,
      employeeId: map['employeeId'] as String? ?? '',
      managerId: map['managerId'] as String? ?? '',
      leaveType: map['leaveType'] as String? ?? 'casual',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      totalDays: (map['totalDays'] as num?)?.toDouble() ?? 1.0,
      reason: map['reason'] as String? ?? '',
      attachmentUrl: map['attachmentUrl'] as String?,
      status: map['status'] as String? ?? 'pending',
      rejectionReason: map['rejectionReason'] as String?,
      approvedBy: map['approvedBy'] as String?,
      actionedAt: (map['actionedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory LeaveRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LeaveRequestModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'managerId': managerId,
      'leaveType': leaveType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalDays': totalDays,
      'reason': reason,
      'attachmentUrl': attachmentUrl,
      'status': status,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'actionedAt': actionedAt != null ? Timestamp.fromDate(actionedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
