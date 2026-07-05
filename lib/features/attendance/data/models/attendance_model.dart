import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';
import 'break_model.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    required super.dateKey,
    required super.shiftId,
    required super.officeId,
    super.checkIn,
    super.checkOut,
    required super.breaks,
    required super.totalBreakMinutes,
    required super.grossDurationMinutes,
    required super.netWorkingMinutes,
    required super.overtimeMinutes,
    required super.status,
    required super.isRegularized,
    required super.riskScore,
    required super.riskFlags,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String docId) {
    // Parse checkIn
    PunchDetails? checkInDetails;
    if (map['checkIn'] != null) {
      final ci = map['checkIn'] as Map<String, dynamic>;
      checkInDetails = PunchDetails(
        timestamp: (ci['timestamp'] as Timestamp).toDate(),
        latitude: (ci['latitude'] as num).toDouble(),
        longitude: (ci['longitude'] as num).toDouble(),
        accuracy: (ci['accuracy'] as num).toDouble(),
        distanceFromOffice: (ci['distanceFromOffice'] as num).toDouble(),
        selfieUrl: ci['selfieUrl'] as String? ?? '',
        deviceId: ci['deviceId'] as String? ?? '',
        verificationMethod: ci['verificationMethod'] as String? ?? 'gps_selfie',
        lateMinutes: ci['lateMinutes'] as int? ?? 0,
        mockLocationDetected: ci['mockLocationDetected'] as bool? ?? false,
      );
    }

    // Parse checkOut
    PunchDetails? checkOutDetails;
    if (map['checkOut'] != null) {
      final co = map['checkOut'] as Map<String, dynamic>;
      checkOutDetails = PunchDetails(
        timestamp: (co['timestamp'] as Timestamp).toDate(),
        latitude: (co['latitude'] as num).toDouble(),
        longitude: (co['longitude'] as num).toDouble(),
        accuracy: (co['accuracy'] as num).toDouble(),
        distanceFromOffice: (co['distanceFromOffice'] as num).toDouble(),
        selfieUrl: co['selfieUrl'] as String? ?? '',
        deviceId: co['deviceId'] as String? ?? '',
        verificationMethod: co['verificationMethod'] as String? ?? 'gps_selfie',
        lateMinutes: co['lateMinutes'] as int? ?? 0,
        mockLocationDetected: co['mockLocationDetected'] as bool? ?? false,
      );
    }

    // Parse breaks
    final List<BreakModel> parsedBreaks = [];
    if (map['breaks'] != null) {
      final breakList = map['breaks'] as List;
      for (var b in breakList) {
        parsedBreaks.add(BreakModel.fromMap(b as Map<String, dynamic>));
      }
    }

    return AttendanceModel(
      id: docId,
      employeeId: map['employeeId'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      shiftId: map['shiftId'] as String? ?? '',
      officeId: map['officeId'] as String? ?? '',
      checkIn: checkInDetails,
      checkOut: checkOutDetails,
      breaks: parsedBreaks,
      totalBreakMinutes: map['totalBreakMinutes'] as int? ?? 0,
      grossDurationMinutes: map['grossDurationMinutes'] as int? ?? 0,
      netWorkingMinutes: map['netWorkingMinutes'] as int? ?? 0,
      overtimeMinutes: map['overtimeMinutes'] as int? ?? 0,
      status: map['status'] as String? ?? 'absent',
      isRegularized: map['isRegularized'] as bool? ?? false,
      riskScore: (map['riskScore'] as num?)?.toDouble() ?? 0.0,
      riskFlags: List<String>.from(map['riskFlags'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AttendanceModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'dateKey': dateKey,
      'shiftId': shiftId,
      'officeId': officeId,
      'checkIn': checkIn != null ? _punchDetailsToMap(checkIn!) : null,
      'checkOut': checkOut != null ? _punchDetailsToMap(checkOut!) : null,
      'breaks': breaks.map((b) => (b as BreakModel).toMap()).toList(),
      'totalBreakMinutes': totalBreakMinutes,
      'grossDurationMinutes': grossDurationMinutes,
      'netWorkingMinutes': netWorkingMinutes,
      'overtimeMinutes': overtimeMinutes,
      'status': status,
      'isRegularized': isRegularized,
      'riskScore': riskScore,
      'riskFlags': riskFlags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> _punchDetailsToMap(PunchDetails details) {
    return {
      'timestamp': Timestamp.fromDate(details.timestamp),
      'latitude': details.latitude,
      'longitude': details.longitude,
      'accuracy': details.accuracy,
      'distanceFromOffice': details.distanceFromOffice,
      'selfieUrl': details.selfieUrl,
      'deviceId': details.deviceId,
      'verificationMethod': details.verificationMethod,
      'lateMinutes': details.lateMinutes,
      'mockLocationDetected': details.mockLocationDetected,
    };
  }
}
