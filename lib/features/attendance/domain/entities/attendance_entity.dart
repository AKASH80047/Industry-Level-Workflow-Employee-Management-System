import 'package:flutter/foundation.dart';
import 'break_entity.dart';

@immutable
class AttendanceEntity {
  final String id;
  final String employeeId;
  final String dateKey; // format yyyyMMdd
  final String shiftId;
  final String officeId;
  final PunchDetails? checkIn;
  final PunchDetails? checkOut;
  final List<BreakEntity> breaks;
  final int totalBreakMinutes;
  final int grossDurationMinutes;
  final int netWorkingMinutes;
  final int overtimeMinutes;
  final String status; // 'present' | 'absent' | 'late' | 'half_day' | 'on_leave' | 'holiday' | 'week_off' | 'pending_regularization'
  final bool isRegularized;
  final double riskScore;
  final List<String> riskFlags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceEntity({
    required this.id,
    required this.employeeId,
    required this.dateKey,
    required this.shiftId,
    required this.officeId,
    this.checkIn,
    this.checkOut,
    required this.breaks,
    required this.totalBreakMinutes,
    required this.grossDurationMinutes,
    required this.netWorkingMinutes,
    required this.overtimeMinutes,
    required this.status,
    required this.isRegularized,
    required this.riskScore,
    required this.riskFlags,
    required this.createdAt,
    required this.updatedAt,
  });

  AttendanceEntity copyWith({
    String? id,
    String? employeeId,
    String? dateKey,
    String? shiftId,
    String? officeId,
    PunchDetails? checkIn,
    PunchDetails? checkOut,
    List<BreakEntity>? breaks,
    int? totalBreakMinutes,
    int? grossDurationMinutes,
    int? netWorkingMinutes,
    int? overtimeMinutes,
    String? status,
    bool? isRegularized,
    double? riskScore,
    List<String>? riskFlags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      dateKey: dateKey ?? this.dateKey,
      shiftId: shiftId ?? this.shiftId,
      officeId: officeId ?? this.officeId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      breaks: breaks ?? this.breaks,
      totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
      grossDurationMinutes: grossDurationMinutes ?? this.grossDurationMinutes,
      netWorkingMinutes: netWorkingMinutes ?? this.netWorkingMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      status: status ?? this.status,
      isRegularized: isRegularized ?? this.isRegularized,
      riskScore: riskScore ?? this.riskScore,
      riskFlags: riskFlags ?? this.riskFlags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@immutable
class PunchDetails {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double distanceFromOffice;
  final String selfieUrl;
  final String deviceId;
  final String verificationMethod; // 'gps_selfie' | 'qr' | 'manual'
  final int lateMinutes;
  final bool mockLocationDetected;

  const PunchDetails({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.distanceFromOffice,
    required this.selfieUrl,
    required this.deviceId,
    required this.verificationMethod,
    required this.lateMinutes,
    required this.mockLocationDetected,
  });
}
