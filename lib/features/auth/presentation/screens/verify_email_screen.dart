import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../../../../app/router/route_constants.dart';
import '../../../../core/theme/app_theme.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final isVerified = await authRepo.isEmailVerified();

      if (isVerified) {
        final authState = ref.refresh(authStateProvider);
        final user = authState.value;
        
        if (!mounted) return;

        if (user != null) {
          if (user.role == 'admin') {
            context.go(RoutePaths.adminDashboard);
          } else if (user.role == 'manager') {
            context.go(RoutePaths.managerDashboard);
          } else {
            context.go(RoutePaths.employeeDashboard);
          }
        }
      } else {
        setState(() {
          _message = 'Email address is still not verified. Please check your inbox or spam folder.';
        });
      }
    } catch (e) {
      setState(() {
        _message = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.sendEmailVerification();
      setState(() {
        _message = 'A new verification link has been successfully dispatched to your email.';
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 72,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verify Your Account',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We have sent a verification link to your registered email address. Please click that link to activate your system permissions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (_message != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _checkVerificationStatus,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('I Have Verified Email'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _resendVerificationEmail,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Resend Verification Link'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
