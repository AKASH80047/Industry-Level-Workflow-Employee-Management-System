import '../entities/leave_request_entity.dart';

abstract class LeaveRepository {
  /// Submit a new leave application
  Future<void> submitLeaveRequest({
    required LeaveRequestEntity request,
  });

  /// Listen to leaves applied by a specific employee
  Stream<List<LeaveRequestEntity>> getEmployeeLeaveRequestsStream({
    required String employeeId,
  });

  /// Listen to leaves needing approval by a specific manager
  Stream<List<LeaveRequestEntity>> getManagerLeaveRequestsStream({
    required String managerId,
  });

  /// Approve or reject a leave request inside a safe database transaction updating leave balances
  Future<void> updateLeaveRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
    required String managerId,
  });
}
