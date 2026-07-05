import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream of current authenticated user metadata from DB
  Stream<UserEntity?> get authStateChanges;

  /// Gets the currently cached user ID if any
  String? get currentUserId;

  /// Signs in using email and password credentials
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Logs out of the current active session
  Future<void> signOut();

  /// Requests a password reset link
  Future<void> sendPasswordReset({required String email});

  /// Checks if the user's email address has been verified
  Future<bool> isEmailVerified();

  /// Requests a new verification email
  Future<void> sendEmailVerification();

  /// Authenticate session using Google Auth provider
  Future<UserEntity> signInWithGoogle();

  /// Dispatches a verification code SMS to phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(Exception error) onVerificationFailed,
  });

  /// Submit OTP verification code to log in
  Future<UserEntity> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  });

  /// Updates or binds a device footprint to an employee account
  Future<void> registerDevice({
    required String uid,
    required String deviceId,
    required String deviceModel,
    required String deviceOS,
  });
}
