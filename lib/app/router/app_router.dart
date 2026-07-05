import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/dashboard/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/unauthorized_screen.dart';
import '../../features/dashboard/presentation/screens/account_blocked_screen.dart';
import '../../features/dashboard/presentation/screens/employee_dashboard_screen.dart';
import '../../features/attendance/presentation/screens/check_in_screen.dart';
import '../../features/attendance/presentation/screens/attendance_history_screen.dart';
import '../../features/leave/presentation/screens/leave_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/payroll/presentation/screens/payslip_list_screen.dart';
import '../../features/manager/presentation/screens/manager_dashboard_screen.dart';
import '../../features/manager/presentation/screens/manager_team_screen.dart';
import '../../features/manager/presentation/screens/manager_approvals_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_employees_screen.dart';
import '../../features/admin/presentation/screens/admin_attendance_screen.dart';
import '../../features/admin/presentation/screens/admin_leaves_screen.dart';
import '../../features/admin/presentation/screens/admin_shifts_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../features/admin/presentation/screens/admin_payroll_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_audit_logs_screen.dart';
import 'route_constants.dart';

/// Exposes the GoRouter instance as a Riverpod provider
final routerProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      // If authState is loading, stay on splash screen
      if (authStateAsync.isLoading) return null;

      final user = authStateAsync.value;
      final isLoggedIn = user != null;
      final location = state.matchedLocation;

      // Unauthenticated state redirection rules
      if (!isLoggedIn) {
        // Allow unauthenticated paths
        if (location == RoutePaths.login ||
            location == RoutePaths.forgotPassword ||
            location == RoutePaths.onboarding ||
            location == RoutePaths.splash) {
          return null;
        }
        return RoutePaths.login;
      }

      // Check account status first
      if (user.isBlocked) {
        return RoutePaths.accountBlocked;
      }
      if (!user.isActive) {
        return RoutePaths.unauthorized;
      }

      // Authenticated users trying to reach auth screens
      if (location == RoutePaths.login ||
          location == RoutePaths.forgotPassword ||
          location == RoutePaths.onboarding ||
          location == RoutePaths.splash) {
        if (user.role == 'admin') return RoutePaths.adminDashboard;
        if (user.role == 'manager') return RoutePaths.managerDashboard;
        return RoutePaths.employeeDashboard;
      }

      // Role-Based Route Guards
      if (location.startsWith('/admin') && user.role != 'admin') {
        return RoutePaths.unauthorized;
      }
      if (location.startsWith('/manager') && user.role != 'manager' && user.role != 'admin') {
        return RoutePaths.unauthorized;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        name: RouteNames.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: RoutePaths.unauthorized,
        name: RouteNames.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: RoutePaths.accountBlocked,
        name: RouteNames.accountBlocked,
        builder: (context, state) => const AccountBlockedScreen(),
      ),

      // Employee Scope Routes
      GoRoute(
        path: RoutePaths.employeeDashboard,
        name: RouteNames.employeeDashboard,
        builder: (context, state) => const EmployeeDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.employeePunch,
        name: RouteNames.employeePunch,
        builder: (context, state) => const CheckInScreen(),
      ),
      GoRoute(
        path: RoutePaths.employeeLeaves,
        name: RouteNames.employeeLeaves,
        builder: (context, state) => const LeaveDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.employeeHistory,
        name: RouteNames.employeeHistory,
        builder: (context, state) => const AttendanceHistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.employeeProfile,
        name: RouteNames.employeeProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.employeePayslips,
        name: RouteNames.employeePayslips,
        builder: (context, state) => const PayslipListScreen(),
      ),

      // Manager Scope Routes
      GoRoute(
        path: RoutePaths.managerDashboard,
        name: RouteNames.managerDashboard,
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.managerTeam,
        name: RouteNames.managerTeam,
        builder: (context, state) => const ManagerTeamScreen(),
      ),
      GoRoute(
        path: RoutePaths.managerApprovals,
        name: RouteNames.managerApprovals,
        builder: (context, state) => const ManagerApprovalsScreen(),
      ),

      // Admin Scope Routes
      GoRoute(
        path: RoutePaths.adminDashboard,
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminEmployees,
        name: RouteNames.adminEmployees,
        builder: (context, state) => const AdminEmployeesScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAttendance,
        name: RouteNames.adminAttendance,
        builder: (context, state) => const AdminAttendanceScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminLeaves,
        name: RouteNames.adminLeaves,
        builder: (context, state) => const AdminLeavesScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminShifts,
        name: RouteNames.adminShifts,
        builder: (context, state) => const AdminShiftsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminReports,
        name: RouteNames.adminReports,
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminPayroll,
        name: RouteNames.adminPayroll,
        builder: (context, state) => const AdminPayrollScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminSettings,
        name: RouteNames.adminSettings,
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAuditLogs,
        name: RouteNames.adminAuditLogs,
        builder: (context, state) => const AdminAuditLogsScreen(),
      ),
    ],
  );
});
