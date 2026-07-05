import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../providers/auth_providers.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../app/router/route_constants.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Email / Password ──────────────────────────────────────────────────────
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ── Register ──────────────────────────────────────────────────────────────
  final _registerFormKey = GlobalKey<FormState>();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmController = TextEditingController();
  bool _obscureReg = true;
  bool _obscureConfirm = true;

  // ── Phone OTP ─────────────────────────────────────────────────────────────
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  fb_auth.ConfirmationResult? _confirmationResult; // Web phone auth result

  // ── Shared ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _errorMessage = null;
          _successMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _handlePostAuth(UserEntity user) {
    if (!mounted) return;
    if (user.isBlocked) {
      context.go(RoutePaths.accountBlocked);
      return;
    }
    if (user.role == 'admin') {
      context.go(RoutePaths.adminDashboard);
    } else if (user.role == 'manager') {
      context.go(RoutePaths.managerDashboard);
    } else {
      context.go(RoutePaths.employeeDashboard);
    }
  }

  // ── Email Login ────────────────────────────────────────────────────────────
  Future<void> _handleEmailLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      _handlePostAuth(user);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      // Create user in Firebase Auth
      final credential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _regEmailController.text.trim(),
        password: _regPasswordController.text,
      );
      // Send email verification
      await credential.user?.sendEmailVerification();

      if (!mounted) return;
      setState(() {
        _successMessage =
            '✅ Account created! Check your email to verify before signing in.';
        _errorMessage = null;
        _regEmailController.clear();
        _regPasswordController.clear();
        _regConfirmController.clear();
      });
      // Switch to Login tab
      _tabController.animateTo(0);
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Registration failed');
    } catch (e) {
      _setError('Registration error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── Phone OTP (Web-compatible) ────────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !phone.startsWith('+')) {
      _setError('Enter phone with country code, e.g. +91XXXXXXXXXX');
      return;
    }
    _setLoading(true);
    try {
      // Web: signInWithPhoneNumber uses reCAPTCHA automatically
      final result = await fb_auth.FirebaseAuth.instance
          .signInWithPhoneNumber(phone);
      if (!mounted) return;
      setState(() {
        _confirmationResult = result;
        _otpSent = true;
        _errorMessage = null;
        _successMessage = '✅ OTP sent to $phone';
      });
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Failed to send OTP');
    } catch (e) {
      _setError('OTP error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _setError('Enter the 6-digit OTP');
      return;
    }
    if (_confirmationResult == null) {
      _setError('Session expired. Please request OTP again.');
      return;
    }
    _setLoading(true);
    try {
      final credential = await _confirmationResult!.confirm(code);
      final fbUser = credential.user;
      if (fbUser == null) throw Exception('Authentication failed');
      // Fetch or create user doc via repository
      final user = await ref.read(authRepositoryProvider)
          .signInWithPhoneCredential(
        verificationId: 'web_confirm', // placeholder — not used on web path
        smsCode: code,
      );
      _handlePostAuth(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Invalid OTP');
    } catch (e) {
      _setError('Verification failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  Future<void> _handleGoogle() async {
    _setLoading(true);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      _handlePostAuth(user);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  void _setError(String msg) {
    if (mounted) setState(() => _errorMessage = msg);
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo ───────────────────────────────────────────────────
                const Icon(
                  Icons.fingerprint_rounded,
                  size: 72,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Workforce Hub',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enterprise Attendance & Management',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 28),

                // ── Status Banners ─────────────────────────────────────────
                if (_successMessage != null) ...[
                  _banner(_successMessage!, Colors.green, Icons.check_circle_outline),
                  const SizedBox(height: 12),
                ],
                if (_errorMessage != null) ...[
                  _banner(_errorMessage!, theme.colorScheme.error, Icons.error_outline),
                  const SizedBox(height: 12),
                ],

                // ── Tabs ───────────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        isDark ? Colors.white60 : Colors.black54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Register'),
                      Tab(text: 'Phone OTP'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Tab Content ────────────────────────────────────────────
                SizedBox(
                  height: 340,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEmailLoginTab(isDark),
                      _buildRegisterTab(),
                      _buildPhoneTab(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // ── Divider ────────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Google Button ──────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogle,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28,
                      color: AppTheme.primaryColor),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Email / Sign-in Tab ────────────────────────────────────────────────────
  Widget _buildEmailLoginTab(bool isDark) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your password';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(RoutePaths.forgotPassword),
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Text('Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Register Tab ───────────────────────────────────────────────────────────
  Widget _buildRegisterTab() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter an email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regPasswordController,
            obscureText: _obscureReg,
            decoration: InputDecoration(
              labelText: 'Password (min 6 chars)',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscureReg
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscureReg = !_obscureReg),
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regConfirmController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_reset_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v != _regPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Text('Create Account',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Phone OTP Tab ──────────────────────────────────────────────────────────
  Widget _buildPhoneTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          enabled: !_otpSent,
          decoration: const InputDecoration(
            labelText: 'Phone Number (e.g. +919876543210)',
            prefixIcon: Icon(Icons.phone_android_rounded),
            helperText: 'Include country code: +91 for India, +1 for USA',
          ),
        ),
        if (_otpSent) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: '6-Digit OTP',
              prefixIcon: Icon(Icons.sms_outlined),
              counterText: '',
              helperText: 'Enter the code sent to your phone',
            ),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : (_otpSent ? _handleVerifyOtp : _handleSendOtp),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : Text(
                  _otpSent ? 'Verify OTP & Sign In' : 'Send OTP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
        if (_otpSent) ...[
          TextButton(
            onPressed: () => setState(() {
              _otpSent = false;
              _confirmationResult = null;
              _otpController.clear();
              _successMessage = null;
            }),
            child: const Text('← Change Phone Number'),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '🔒 Secured by Firebase reCAPTCHA. An OTP will be sent via SMS.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // ── Helper: Banner ─────────────────────────────────────────────────────────
  Widget _banner(String msg, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
