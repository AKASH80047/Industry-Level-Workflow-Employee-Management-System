import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/regularization_request_entity.dart';

class RegularizationRequestModel extends RegularizationRequestEntity {
  const RegularizationRequestModel({
    required super.id,
    required super.attendanceId,
    required super.employeeId,
    required super.managerId,
    required super.dateKey,
    required super.issueType,
    super.requestedCheckIn,
    super.requestedCheckOut,
    required super.reason,
    required super.status,
    super.rejectionReason,
    super.actionedAt,
    required super.createdAt,
  });

  factory RegularizationRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return RegularizationRequestModel(
      id: docId,
      attendanceId: map['attendanceId'] as String? ?? '',
      employeeId: map['employeeId'] as String? ?? '',
      managerId: map['managerId'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      issueType: map['issueType'] as String? ?? 'forgot_check_in',
      requestedCheckIn: (map['requestedCheckIn'] as Timestamp?)?.toDate(),
      requestedCheckOut: (map['requestedCheckOut'] as Timestamp?)?.toDate(),
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      rejectionReason: map['rejectionReason'] as String?,
      actionedAt: (map['actionedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory RegularizationRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RegularizationRequestModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'employeeId': employeeId,
      'managerId': managerId,
      'dateKey': dateKey,
      'issueType': issueType,
      'requestedCheckIn': requestedCheckIn != null ? Timestamp.fromDate(requestedCheckIn!) : null,
      'requestedCheckOut': requestedCheckOut != null ? Timestamp.fromDate(requestedCheckOut!) : null,
      'reason': reason,
      'status': status,
      'rejectionReason': rejectionReason,
      'actionedAt': actionedAt != null ? Timestamp.fromDate(actionedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
