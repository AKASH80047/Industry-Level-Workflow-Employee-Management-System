import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  /// Stream of today's attendance log for the given employee
  Stream<AttendanceEntity?> getTodayAttendanceStream({
    required String employeeId,
    required String dateKey,
  });

  /// Get the paginated attendance history list for the employee
  Future<List<AttendanceEntity>> getAttendanceHistory({
    required String employeeId,
    int limit = 30,
    String? startAfterId,
  });

  /// Registers check-in details inside a secure database transaction
  Future<void> registerCheckIn({
    required String employeeId,
    required String dateKey,
    required String shiftId,
    required String officeId,
    required PunchDetails checkInDetails,
    required String status,
  });

  /// Registers check-out and computes overall duration parameters
  Future<void> registerCheckOut({
    required String employeeId,
    required String dateKey,
    required PunchDetails checkOutDetails,
    required int requiredShiftDurationMinutes,
  });

  /// Start a tea/lunch break
  Future<void> startBreak({
    required String employeeId,
    required String dateKey,
    required String breakType,
  });

  /// End the currently active break
  Future<void> endBreak({
    required String employeeId,
    required String dateKey,
  });
}
