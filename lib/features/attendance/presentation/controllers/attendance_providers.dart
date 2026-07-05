import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'package:intl/intl.dart';

/// Provider for the AttendanceRepository implementation
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl();
});

/// StreamProvider that listens to today's attendance record for the logged-in employee
final todayAttendanceProvider = StreamProvider<AttendanceEntity?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(attendanceRepositoryProvider);
  final dateKey = DateFormat('yyyyMMdd').format(DateTime.now());

  return repository.getTodayAttendanceStream(
    employeeId: userId,
    dateKey: dateKey,
  );
});

/// FutureProvider that fetches the employee's attendance logs history
final attendanceHistoryProvider = FutureProvider<List<AttendanceEntity>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(attendanceRepositoryProvider);
  return await repository.getAttendanceHistory(employeeId: userId);
});

/// StateProvider for tracking active break timer on the client
final activeBreakTimerProvider = StreamProvider<int>((ref) {
  final todayAttendance = ref.watch(todayAttendanceProvider).value;
  if (todayAttendance == null) return Stream.value(0);

  // Check if there is an active break (endTime is null)
  final activeBreak = todayAttendance.breaks.cast<dynamic>().firstWhere(
        (b) => b.endTime == null,
        orElse: () => null,
      );

  if (activeBreak == null) return Stream.value(0);

  final startTime = activeBreak.startTime as DateTime;
  return Stream.periodic(const Duration(seconds: 1), (i) {
    return DateTime.now().difference(startTime).inSeconds;
  });
});
