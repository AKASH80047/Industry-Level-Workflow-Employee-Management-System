import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/regularization_request_entity.dart';
import '../../domain/repositories/regularization_repository.dart';
import '../models/regularization_request_model.dart';
import '../../../../core/constants/firebase_collections.dart';

class RegularizationRepositoryImpl implements RegularizationRepository {
  final FirebaseFirestore _firestore;

  RegularizationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitRegularizationRequest({
    required RegularizationRequestEntity request,
  }) async {
    final batch = _firestore.batch();
    final ref = _firestore.collection(FirebaseCollections.regularizationRequests).doc();

    final model = RegularizationRequestModel(
      id: ref.id,
      attendanceId: request.attendanceId,
      employeeId: request.employeeId,
      managerId: request.managerId,
      dateKey: request.dateKey,
      issueType: request.issueType,
      requestedCheckIn: request.requestedCheckIn,
      requestedCheckOut: request.requestedCheckOut,
      reason: request.reason,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    batch.set(ref, model.toMap());

    // Flag the attendance sheet as pending regularization
    final attendanceRef = _firestore
        .collection(FirebaseCollections.attendance)
        .doc(request.attendanceId);
    
    batch.update(attendanceRef, {
      'status': 'pending_regularization',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Stream<List<RegularizationRequestEntity>> getEmployeeRegularizationsStream({
    required String employeeId,
  }) {
    return _firestore
        .collection(FirebaseCollections.regularizationRequests)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => RegularizationRequestModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<RegularizationRequestEntity>> getManagerRegularizationsStream({
    required String managerId,
  }) {
    return _firestore
        .collection(FirebaseCollections.regularizationRequests)
        .where('managerId', isEqualTo: managerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => RegularizationRequestModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateRegularizationStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
    required String managerId,
  }) async {
    final requestRef = _firestore.collection(FirebaseCollections.regularizationRequests).doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final requestSnapshot = await transaction.get(requestRef);
      if (!requestSnapshot.exists) {
        throw Exception('Regularization request not found.');
      }

      final regularization = RegularizationRequestModel.fromFirestore(requestSnapshot);
      if (regularization.status != 'pending') {
        throw Exception('This request has already been processed.');
      }

      final attendanceId = regularization.attendanceId;
      final attendanceRef = _firestore.collection(FirebaseCollections.attendance).doc(attendanceId);

      if (status == 'approved') {
        final attendanceSnapshot = await transaction.get(attendanceRef);
        
        // Calculate durations
        final checkInTime = regularization.requestedCheckIn ?? DateTime.now();
        final checkOutTime = regularization.requestedCheckOut ?? DateTime.now();
        final grossMinutes = checkOutTime.difference(checkInTime).inMinutes;
        final netMinutes = grossMinutes; // Deduct breaks if applicable, else gross
        final overtime = (netMinutes > 480) ? (netMinutes - 480) : 0; // Default 8 hrs shift

        final finalStatus = (netMinutes >= 240) ? 'present' : 'half_day';

        final checkInMap = {
          'timestamp': Timestamp.fromDate(checkInTime),
          'latitude': 0.0,
          'longitude': 0.0,
          'accuracy': 0.0,
          'distanceFromOffice': 0.0,
          'selfieUrl': 'manual_correction',
          'deviceId': 'manual_correction',
          'verificationMethod': 'manual',
          'lateMinutes': 0,
          'mockLocationDetected': false,
        };

        final checkOutMap = {
          'timestamp': Timestamp.fromDate(checkOutTime),
          'latitude': 0.0,
          'longitude': 0.0,
          'accuracy': 0.0,
          'distanceFromOffice': 0.0,
          'selfieUrl': 'manual_correction',
          'deviceId': 'manual_correction',
          'verificationMethod': 'manual',
          'lateMinutes': 0,
          'mockLocationDetected': false,
        };

        if (attendanceSnapshot.exists) {
          transaction.update(attendanceRef, {
            'checkIn': checkInMap,
            'checkOut': checkOutMap,
            'grossDurationMinutes': grossMinutes,
            'netWorkingMinutes': netMinutes,
            'overtimeMinutes': overtime,
            'status': finalStatus,
            'isRegularized': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Initialize fresh corrected attendance sheet
          final newAttendance = {
            'employeeId': regularization.employeeId,
            'dateKey': regularization.dateKey,
            'shiftId': 'manual',
            'officeId': 'manual',
            'checkIn': checkInMap,
            'checkOut': checkOutMap,
            'breaks': [],
            'totalBreakMinutes': 0,
            'grossDurationMinutes': grossMinutes,
            'netWorkingMinutes': netMinutes,
            'overtimeMinutes': overtime,
            'status': finalStatus,
            'isRegularized': true,
            'riskScore': 0.0,
            'riskFlags': [],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          transaction.set(attendanceRef, newAttendance);
        }
      } else {
        // If rejected, restore attendance sheet status from pending_regularization back to absent/missed punch
        final attendanceSnapshot = await transaction.get(attendanceRef);
        if (attendanceSnapshot.exists) {
          transaction.update(attendanceRef, {
            'status': 'absent', // Revert to absent
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Update Request status
      transaction.update(requestRef, {
        'status': status,
        'rejectionReason': rejectionReason,
        'actionedAt': FieldValue.serverTimestamp(),
      });

      // Log to audits
      final auditRef = _firestore.collection(FirebaseCollections.auditLogs).doc();
      transaction.set(auditRef, {
        'id': auditRef.id,
        'actorId': managerId,
        'actorRole': 'manager',
        'action': 'action_regularization_request',
        'entityType': 'regularization_request',
        'entityId': requestId,
        'afterValues': {'status': status, 'rejectionReason': rejectionReason},
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
