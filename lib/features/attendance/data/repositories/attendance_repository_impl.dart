import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';
import '../models/break_model.dart';
import '../../../../core/constants/firebase_collections.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirebaseFirestore _firestore;

  AttendanceRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<AttendanceEntity?> getTodayAttendanceStream({
    required String employeeId,
    required String dateKey,
  }) {
    final docId = '${employeeId}_$dateKey';
    return _firestore
        .collection(FirebaseCollections.attendance)
        .doc(docId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return AttendanceModel.fromFirestore(snapshot);
    });
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory({
    required String employeeId,
    int limit = 30,
    String? startAfterId,
  }) async {
    var query = _firestore
        .collection(FirebaseCollections.attendance)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('dateKey', descending: true)
        .limit(limit);

    if (startAfterId != null) {
      final startAfterDoc = await _firestore
          .collection(FirebaseCollections.attendance)
          .doc(startAfterId)
          .get();
      if (startAfterDoc.exists) {
        query = query.startAfterDocument(startAfterDoc);
      }
    }

    final snap = await query.get();
    return snap.docs.map((doc) => AttendanceModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> registerCheckIn({
    required String employeeId,
    required String dateKey,
    required String shiftId,
    required String officeId,
    required PunchDetails checkInDetails,
    required String status,
  }) async {
    final docId = '${employeeId}_$dateKey';
    final docRef = _firestore.collection(FirebaseCollections.attendance).doc(docId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (docSnapshot.exists) {
        throw Exception('Attendance check-in record already exists for today.');
      }

      final checkInMap = {
        'timestamp': Timestamp.fromDate(checkInDetails.timestamp),
        'latitude': checkInDetails.latitude,
        'longitude': checkInDetails.longitude,
        'accuracy': checkInDetails.accuracy,
        'distanceFromOffice': checkInDetails.distanceFromOffice,
        'selfieUrl': checkInDetails.selfieUrl,
        'deviceId': checkInDetails.deviceId,
        'verificationMethod': checkInDetails.verificationMethod,
        'lateMinutes': checkInDetails.lateMinutes,
        'mockLocationDetected': checkInDetails.mockLocationDetected,
      };

      final newAttendance = {
        'employeeId': employeeId,
        'dateKey': dateKey,
        'shiftId': shiftId,
        'officeId': officeId,
        'checkIn': checkInMap,
        'checkOut': null,
        'breaks': [],
        'totalBreakMinutes': 0,
        'grossDurationMinutes': 0,
        'netWorkingMinutes': 0,
        'overtimeMinutes': 0,
        'status': status,
        'isRegularized': false,
        'riskScore': checkInDetails.mockLocationDetected ? 1.0 : 0.0,
        'riskFlags': checkInDetails.mockLocationDetected ? ['mock_gps_detected'] : [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(docRef, newAttendance);

      // Log to audits
      final auditRef = _firestore.collection(FirebaseCollections.auditLogs).doc();
      transaction.set(auditRef, {
        'id': auditRef.id,
        'actorId': employeeId,
        'actorRole': 'employee',
        'action': 'check_in',
        'entityType': 'attendance',
        'entityId': docId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> registerCheckOut({
    required String employeeId,
    required String dateKey,
    required PunchDetails checkOutDetails,
    required int requiredShiftDurationMinutes,
  }) async {
    final docId = '${employeeId}_$dateKey';
    final docRef = _firestore.collection(FirebaseCollections.attendance).doc(docId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) {
        throw Exception('Check-in record missing. Cannot process check-out.');
      }

      final attendance = AttendanceModel.fromFirestore(docSnapshot);
      if (attendance.checkOut != null) {
        throw Exception('Attendance check-out has already been registered.');
      }

      final checkInTime = attendance.checkIn!.timestamp;
      final checkOutTime = checkOutDetails.timestamp;
      
      // Calculations
      final grossMinutes = checkOutTime.difference(checkInTime).inMinutes;
      final breakMinutes = attendance.totalBreakMinutes;
      final netMinutes = grossMinutes - breakMinutes;
      final overtime = (netMinutes > requiredShiftDurationMinutes)
          ? (netMinutes - requiredShiftDurationMinutes)
          : 0;

      // Determine final status
      String finalStatus = attendance.status;
      if (attendance.status == 'present' || attendance.status == 'late') {
        if (netMinutes < 240) { // Under 4 hours is absent/halfday depending on policy
          finalStatus = 'half_day';
        }
      }

      final checkOutMap = {
        'timestamp': Timestamp.fromDate(checkOutTime),
        'latitude': checkOutDetails.latitude,
        'longitude': checkOutDetails.longitude,
        'accuracy': checkOutDetails.accuracy,
        'distanceFromOffice': checkOutDetails.distanceFromOffice,
        'selfieUrl': checkOutDetails.selfieUrl,
        'deviceId': checkOutDetails.deviceId,
        'verificationMethod': checkOutDetails.verificationMethod,
        'lateMinutes': 0,
        'mockLocationDetected': checkOutDetails.mockLocationDetected,
      };

      final List<String> currentFlags = List.from(attendance.riskFlags);
      if (checkOutDetails.mockLocationDetected) {
        currentFlags.add('mock_gps_at_checkout');
      }

      transaction.update(docRef, {
        'checkOut': checkOutMap,
        'grossDurationMinutes': grossMinutes,
        'netWorkingMinutes': netMinutes,
        'overtimeMinutes': overtime,
        'status': finalStatus,
        'riskFlags': currentFlags,
        'riskScore': currentFlags.isNotEmpty ? 1.0 : 0.0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log to audits
      final auditRef = _firestore.collection(FirebaseCollections.auditLogs).doc();
      transaction.set(auditRef, {
        'id': auditRef.id,
        'actorId': employeeId,
        'actorRole': 'employee',
        'action': 'check_out',
        'entityType': 'attendance',
        'entityId': docId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> startBreak({
    required String employeeId,
    required String dateKey,
    required String breakType,
  }) async {
    final docId = '${employeeId}_$dateKey';
    final docRef = _firestore.collection(FirebaseCollections.attendance).doc(docId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) {
        throw Exception('Cannot start break before checking in.');
      }

      final attendance = AttendanceModel.fromFirestore(docSnapshot);
      
      // Ensure there are no active breaks currently
      final hasActiveBreak = attendance.breaks.any((b) => b.endTime == null);
      if (hasActiveBreak) {
        throw Exception('Another break is already active.');
      }

      final newBreak = BreakModel(
        breakType: breakType,
        startTime: DateTime.now(),
      );

      final List<Map<String, dynamic>> updatedBreaks = attendance.breaks
          .map((b) => (b as BreakModel).toMap())
          .toList();
      
      updatedBreaks.add(newBreak.toMap());

      transaction.update(docRef, {
        'breaks': updatedBreaks,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> endBreak({
    required String employeeId,
    required String dateKey,
  }) async {
    final docId = '${employeeId}_$dateKey';
    final docRef = _firestore.collection(FirebaseCollections.attendance).doc(docId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) {
        throw Exception('No active attendance sheet found.');
      }

      final attendance = AttendanceModel.fromFirestore(docSnapshot);
      
      // Find the active break
      final activeIndex = attendance.breaks.indexWhere((b) => b.endTime == null);
      if (activeIndex == -1) {
        throw Exception('No active break found to terminate.');
      }

      final activeBreak = attendance.breaks[activeIndex];
      final endTime = DateTime.now();
      final duration = endTime.difference(activeBreak.startTime).inMinutes;

      final updatedBreak = BreakModel(
        breakType: activeBreak.breakType,
        startTime: activeBreak.startTime,
        endTime: endTime,
        durationMinutes: duration,
      );

      final List<Map<String, dynamic>> updatedBreaksList = attendance.breaks
          .map((b) => (b as BreakModel).toMap())
          .toList();
      
      updatedBreaksList[activeIndex] = updatedBreak.toMap();

      // Recalculate total break duration
      int totalBreakDuration = 0;
      for (var b in updatedBreaksList) {
        totalBreakDuration += (b['durationMinutes'] as int? ?? 0);
      }

      transaction.update(docRef, {
        'breaks': updatedBreaksList,
        'totalBreakMinutes': totalBreakDuration,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
