import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leave_request_entity.dart';
import '../../domain/repositories/leave_repository.dart';
import '../models/leave_request_model.dart';
import '../../../../core/constants/firebase_collections.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final FirebaseFirestore _firestore;

  LeaveRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitLeaveRequest({
    required LeaveRequestEntity request,
  }) async {
    final ref = _firestore.collection(FirebaseCollections.leaveRequests).doc();
    final model = LeaveRequestModel(
      id: ref.id,
      employeeId: request.employeeId,
      managerId: request.managerId,
      leaveType: request.leaveType,
      startDate: request.startDate,
      endDate: request.endDate,
      totalDays: request.totalDays,
      reason: request.reason,
      attachmentUrl: request.attachmentUrl,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await ref.set(model.toMap());

    // Log to audits
    final auditRef = _firestore.collection(FirebaseCollections.auditLogs).doc();
    await auditRef.set({
      'id': auditRef.id,
      'actorId': request.employeeId,
      'actorRole': 'employee',
      'action': 'submit_leave_request',
      'entityType': 'leave_request',
      'entityId': ref.id,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<LeaveRequestEntity>> getEmployeeLeaveRequestsStream({
    required String employeeId,
  }) {
    return _firestore
        .collection(FirebaseCollections.leaveRequests)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => LeaveRequestModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<LeaveRequestEntity>> getManagerLeaveRequestsStream({
    required String managerId,
  }) {
    return _firestore
        .collection(FirebaseCollections.leaveRequests)
        .where('managerId', isEqualTo: managerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => LeaveRequestModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateLeaveRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
    required String managerId,
  }) async {
    final requestRef = _firestore.collection(FirebaseCollections.leaveRequests).doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final requestSnapshot = await transaction.get(requestRef);
      if (!requestSnapshot.exists) {
        throw Exception('Leave request not found.');
      }

      final leaveRequest = LeaveRequestModel.fromFirestore(requestSnapshot);
      if (leaveRequest.status != 'pending') {
        throw Exception('This leave request has already been processed.');
      }

      final employeeId = leaveRequest.employeeId;
      final year = leaveRequest.startDate.year;
      final balanceId = '${employeeId}_$year';
      final balanceRef = _firestore.collection(FirebaseCollections.leaveBalances).doc(balanceId);

      if (status == 'approved') {
        final balanceSnapshot = await transaction.get(balanceRef);
        
        // If balance record doesn't exist, we fallback or initialize it
        double available = 15.0; // Standard annual allotment fallback
        double used = 0.0;
        final typeKey = '${leaveRequest.leaveType}Leave';

        if (balanceSnapshot.exists) {
          final balanceData = balanceSnapshot.data() as Map<String, dynamic>;
          if (balanceData[typeKey] != null) {
            final typeMap = balanceData[typeKey] as Map<String, dynamic>;
            available = (typeMap['allocated'] as num).toDouble();
            used = (typeMap['used'] as num).toDouble();
          }
        }

        if (used + leaveRequest.totalDays > available && leaveRequest.leaveType != 'unpaid') {
          throw Exception('Insufficient leave balance for type: ${leaveRequest.leaveType}.');
        }

        // Deduct/update balance
        final updatedUsed = used + leaveRequest.totalDays;
        
        if (balanceSnapshot.exists) {
          transaction.update(balanceRef, {
            '$typeKey.used': updatedUsed,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Initialize fresh balance document
          final freshBalance = {
            'employeeId': employeeId,
            'year': year,
            'casualLeave': {'allocated': 10.0, 'used': leaveRequest.leaveType == 'casual' ? leaveRequest.totalDays : 0.0},
            'sickLeave': {'allocated': 10.0, 'used': leaveRequest.leaveType == 'sick' ? leaveRequest.totalDays : 0.0},
            'paidLeave': {'allocated': 15.0, 'used': leaveRequest.leaveType == 'paid' ? leaveRequest.totalDays : 0.0},
            'unpaidLeave': {'allocated': 90.0, 'used': leaveRequest.leaveType == 'unpaid' ? leaveRequest.totalDays : 0.0},
            'updatedAt': FieldValue.serverTimestamp(),
          };
          transaction.set(balanceRef, freshBalance);
        }
      }

      // Update Leave Request doc
      final updateData = {
        'status': status,
        'rejectionReason': rejectionReason,
        'approvedBy': managerId,
        'actionedAt': FieldValue.serverTimestamp(),
      };
      transaction.update(requestRef, updateData);

      // Create Audit Log
      final auditRef = _firestore.collection(FirebaseCollections.auditLogs).doc();
      transaction.set(auditRef, {
        'id': auditRef.id,
        'actorId': managerId,
        'actorRole': 'manager',
        'action': 'action_leave_request',
        'entityType': 'leave_request',
        'entityId': requestId,
        'afterValues': {'status': status, 'rejectionReason': rejectionReason},
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
