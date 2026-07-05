import '../entities/regularization_request_entity.dart';

abstract class RegularizationRepository {
  /// Submit a new regularization request
  Future<void> submitRegularizationRequest({
    required RegularizationRequestEntity request,
  });

  /// Listen to regularization logs of a specific employee
  Stream<List<RegularizationRequestEntity>> getEmployeeRegularizationsStream({
    required String employeeId,
  });

  /// Listen to pending regularizations needing approval by a specific manager
  Stream<List<RegularizationRequestEntity>> getManagerRegularizationsStream({
    required String managerId,
  });

  /// Action a regularization request inside a safe database transaction updating the target attendance sheet
  Future<void> updateRegularizationStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
    required String managerId,
  });
}
