import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../../employee/domain/entities/employee_entity.dart';
import '../../../employee/data/models/employee_model.dart';
import '../../../../core/constants/firebase_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Provider for the AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// StreamProvider listening to AuthState changes (FirebaseAuth + Firestore User Profile)
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Provider returning only the current user's UID (null if not logged in)
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.uid;
});

/// Provider returning only the current user's role (null if not logged in)
final currentUserRoleProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.role;
});

/// StreamProvider syncing the detailed Employee Profile details from Firestore
final currentUserProfileProvider = StreamProvider<EmployeeEntity?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }

  // ── Mock / Demo path ──────────────────────────────────────────────────────
  // When Firebase is not configured OR the user logged in with demo credentials
  // (mock UIDs start with 'mock_uid_'), return a local EmployeeModel so every
  // dashboard renders without a Firestore document.
  final isMockUser = userId.startsWith('mock_uid_') || Firebase.apps.isEmpty;
  if (isMockUser) {
    final role = ref.watch(currentUserRoleProvider) ?? 'employee';
    final authState = ref.watch(authStateProvider).value;
    final email = authState?.email ?? '$role@workforce.com';
    final fullName = role == 'admin'
        ? 'Alex Admin'
        : role == 'manager'
            ? 'Mary Manager'
            : 'Emma Employee';
    return Stream.value(EmployeeModel(
      uid: userId,
      employeeId: role == 'admin'
          ? 'EMP-00001'
          : role == 'manager'
              ? 'EMP-00002'
              : 'EMP-00003',
      fullName: fullName,
      email: email,
      phone: '+919876543210',
      joiningDate: DateTime(2023, 1, 1),
      departmentId: 'dept_engineering',
      designationId: role == 'admin'
          ? 'des_cto'
          : role == 'manager'
              ? 'des_manager'
              : 'des_developer',
      shiftId: 'shift_morning',
      officeId: 'office_hq',
      employmentType: 'full_time',
      basicSalary: role == 'admin' ? 15000.0 : role == 'manager' ? 8000.0 : 5000.0,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime.now(),
    ));
  }

  // ── Real Firestore path ────────────────────────────────────────────────────
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.employees)
      .doc(userId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return null;
        return EmployeeModel.fromFirestore(snapshot);
      });
});
