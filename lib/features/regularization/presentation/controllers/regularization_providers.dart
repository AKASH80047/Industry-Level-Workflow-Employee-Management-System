import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/regularization_repository.dart';
import '../../data/repositories/regularization_repository_impl.dart';
import '../../domain/entities/regularization_request_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider for RegularizationRepository implementation
final regularizationRepositoryProvider = Provider<RegularizationRepository>((ref) {
  return RegularizationRepositoryImpl();
});

/// StreamProvider listening to the regularization corrections requested by the current employee
final employeeRegularizationsProvider = StreamProvider<List<RegularizationRequestEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(regularizationRepositoryProvider);
  return repository.getEmployeeRegularizationsStream(employeeId: userId);
});

/// StreamProvider listing the pending regularization requests assigned to the current manager
final managerRegularizationsProvider = StreamProvider<List<RegularizationRequestEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(regularizationRepositoryProvider);
  return repository.getManagerRegularizationsStream(managerId: userId);
});
