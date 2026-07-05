import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/leave_repository.dart';
import '../../data/repositories/leave_repository_impl.dart';
import '../../domain/entities/leave_request_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider for LeaveRepository implementation
final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepositoryImpl();
});

/// StreamProvider listening to the leaves requested by the current employee
final employeeLeaveRequestsProvider = StreamProvider<List<LeaveRequestEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getEmployeeLeaveRequestsStream(employeeId: userId);
});

/// StreamProvider listening to the leave requests assigned to the current manager needing review
final managerLeaveRequestsProvider = StreamProvider<List<LeaveRequestEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getManagerLeaveRequestsStream(managerId: userId);
});
