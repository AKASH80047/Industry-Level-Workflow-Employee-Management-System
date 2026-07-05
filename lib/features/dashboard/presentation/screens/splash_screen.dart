import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/router/route_constants.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleRedirects();
  }

  Future<void> _handleRedirects() async {
    // A brief delay to let the UI display nicely
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (user == null) {
          context.go(RoutePaths.login);
        } else if (user.isBlocked) {
          context.go(RoutePaths.accountBlocked);
        } else if (!user.isActive) {
          context.go(RoutePaths.unauthorized);
        } else {
          // Perform role-based redirects
          if (user.role == 'admin') {
            context.go(RoutePaths.adminDashboard);
          } else if (user.role == 'manager') {
            context.go(RoutePaths.managerDashboard);
          } else {
            context.go(RoutePaths.employeeDashboard);
          }
        }
      },
      loading: () {
        // Keep waiting
      },
      error: (err, stack) {
        context.go(RoutePaths.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF020617), // Deep slate 950
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rotating finger/shield icon to indicate check-in
              Icon(
                Icons.fingerprint_rounded,
                size: 96,
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: 24),
              Text(
                'WORKFORCE HUB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Enterprise Attendance & Management',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 48,
                child: LinearProgressIndicator(
                  color: AppTheme.primaryColor,
                  backgroundColor: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
