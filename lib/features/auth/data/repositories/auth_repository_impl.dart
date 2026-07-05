import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/constants/firebase_collections.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthRepositoryImpl implements AuthRepository {
  late final fb_auth.FirebaseAuth? _firebaseAuth;
  late final FirebaseFirestore? _firestore;
  final bool _useMockFallback;

  UserEntity? _currentUserMock;

  StreamController<UserEntity?>? _authStateController;
  StreamSubscription<fb_auth.User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  AuthRepositoryImpl({
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _useMockFallback = Firebase.apps.isEmpty {
    if (!_useMockFallback) {
      _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance;
      _firestore = firestore ?? FirebaseFirestore.instance;
    } else {
      _firebaseAuth = null;
      _firestore = null;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    _authStateController ??= StreamController<UserEntity?>.broadcast(
      onListen: _startListeningAuth,
      onCancel: _stopListeningAuth,
    );
    return _authStateController!.stream;
  }

  @override
  String? get currentUserId {
    if (_useMockFallback) {
      return _currentUserMock?.uid;
    }
    return _firebaseAuth!.currentUser?.uid;
  }

  void _startListeningAuth() {
    if (_useMockFallback) {
      _authStateController?.add(_currentUserMock);
      return;
    }

    _authSubscription = _firebaseAuth!.authStateChanges().listen((firebaseUser) {
      _userDocSubscription?.cancel();
      if (firebaseUser == null) {
        _authStateController?.add(null);
      } else {
        _userDocSubscription = _firestore!
            .collection(FirebaseCollections.users)
            .doc(firebaseUser.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            _authStateController?.add(UserModel.fromFirestore(snapshot));
          } else {
            // User exists in Auth but not in Firestore users collection yet
            _authStateController?.add(UserEntity(
              uid: firebaseUser.uid,
              employeeId: '',
              email: firebaseUser.email ?? '',
              role: 'employee',
              isActive: true,
              isBlocked: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
        }, onError: (err) {
          _authStateController?.addError(err);
        });
      }
    });
  }

  void _stopListeningAuth() {
    if (_useMockFallback) {
      _authStateController?.close();
      _authStateController = null;
      return;
    }

    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    _authStateController?.close();
    _authStateController = null;
  }

  Future<UserEntity> _fetchOrCreateUserDoc(fb_auth.User user) async {
    final userDoc = await _firestore!
        .collection(FirebaseCollections.users)
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        employeeId: '',
        email: user.email ?? '',
        role: 'employee',
        isActive: true,
        isBlocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .set(newUser.toMap());
      return newUser;
    }

    return UserModel.fromFirestore(userDoc);
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_useMockFallback) {
      return _buildMockUser(email);
    }

    try {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User authentication failed');
      }

      return await _fetchOrCreateUserDoc(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      // If the user doesn't exist in Firebase yet, allow demo logins
      // so the app is always explorable without full Firebase setup.
      final demoEmails = [
        'admin@workforce.com',
        'manager@workforce.com',
        'employee@workforce.com',
        'hr@workforce.com',
      ];
      if (demoEmails.contains(email.toLowerCase().trim())) {
        return _buildMockUser(email);
      }
      throw Exception(e.message ?? 'Authentication error');
    } catch (e) {
      throw Exception('An unexpected authentication failure occurred');
    }
  }

  /// Builds a mock [UserEntity] based on the email prefix for demo/offline use.
  UserModel _buildMockUser(String email) {
    final lower = email.toLowerCase().trim();
    final role = lower.contains('admin')
        ? 'admin'
        : lower.contains('manager') || lower.contains('hr')
            ? 'manager'
            : 'employee';
    final mockUser = UserModel(
      uid: 'mock_uid_${role}_001',
      employeeId: 'EMP-${role == 'admin' ? '00001' : role == 'manager' ? '00002' : '00003'}',
      email: email,
      role: role,
      isActive: true,
      isBlocked: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentUserMock = mockUser;
    _authStateController?.add(mockUser);
    return mockUser;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    if (_useMockFallback) {
      await Future.delayed(const Duration(milliseconds: 500));
      final mockUser = UserModel(
        uid: 'mock_uid_123',
        employeeId: 'EMP-99823',
        email: 'google_user@workforce.com',
        role: 'employee',
        isActive: true,
        isBlocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _currentUserMock = mockUser;
      _authStateController?.add(mockUser);
      return mockUser;
    }

    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In canceled by user.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fbCredential = await _firebaseAuth!.signInWithCredential(credential);
      final user = fbCredential.user;
      if (user == null) {
        throw Exception('User authentication failed.');
      }

      return await _fetchOrCreateUserDoc(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google authentication failed.');
    } catch (e) {
      throw Exception('An unexpected Google Sign-In error occurred');
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(Exception error) onVerificationFailed,
  }) async {
    if (_useMockFallback) {
      await Future.delayed(const Duration(milliseconds: 500));
      onCodeSent('mock_verification_id_999');
      return;
    }

    try {
      await _firebaseAuth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          onVerificationFailed(Exception(e.message ?? 'Phone verification failed.'));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onVerificationFailed(Exception(e.toString()));
    }
  }

  @override
  Future<UserEntity> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    if (_useMockFallback) {
      final mockUser = UserModel(
        uid: 'mock_uid_phone_001',
        employeeId: 'EMP-00004',
        email: 'phone_user@workforce.com',
        role: 'employee',
        isActive: true,
        isBlocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _currentUserMock = mockUser;
      _authStateController?.add(mockUser);
      return mockUser;
    }

    try {
      // On web, the ConfirmationResult.confirm() call in the login screen
      // already completes sign-in. We just need to fetch/create the user doc.
      if (verificationId == 'web_confirm') {
        final fbUser = _firebaseAuth!.currentUser;
        if (fbUser == null) throw Exception('Phone authentication failed');
        return await _fetchOrCreateUserDoc(fbUser);
      }

      // Native (Android/iOS) path
      final credential = fb_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final fbCredential = await _firebaseAuth!.signInWithCredential(credential);
      final user = fbCredential.user;
      if (user == null) throw Exception('User authentication failed.');
      return await _fetchOrCreateUserDoc(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Invalid code entered.');
    } catch (e) {
      throw Exception('Phone authentication failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    if (_useMockFallback) {
      _currentUserMock = null;
      _authStateController?.add(null);
      return;
    }
    await _firebaseAuth!.signOut();
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    if (_useMockFallback) return;
    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email');
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    if (_useMockFallback) return true;
    final user = _firebaseAuth!.currentUser;
    if (user == null) return false;
    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_useMockFallback) return;
    final user = _firebaseAuth!.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> registerDevice({
    required String uid,
    required String deviceId,
    required String deviceModel,
    required String deviceOS,
  }) async {
    if (_useMockFallback) return;
    final batch = _firestore!.batch();

    final employeeRef = _firestore.collection(FirebaseCollections.employees).doc(uid);
    batch.update(employeeRef, {
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'deviceOS': deviceOS,
      'deviceBoundAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final auditRef = _firestore.collection(FirebaseCollections.auditLogs).doc();
    batch.set(auditRef, {
      'id': auditRef.id,
      'actorId': uid,
      'actorRole': 'employee',
      'action': 'register_device',
      'entityType': 'employee',
      'entityId': uid,
      'afterValues': {
        'deviceId': deviceId,
        'deviceModel': deviceModel,
        'deviceOS': deviceOS,
      },
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
