import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  bool _isGoogleSignInInitialized = false;

  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await userCredential.user?.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForFirebaseCode(error.code));
    } catch (_) {
      throw const AuthException(
        'Could not create your account. Please try again.',
      );
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user?.emailVerified == false) {
        await _firebaseAuth.signOut();
        throw const AuthException(
          'Please verify your email before logging in.',
        );
      }

      return userCredential;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForLoginCode(error.code));
    } catch (_) {
      throw const AuthException('Could not log in. Please try again.');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForPasswordResetCode(error.code));
    } catch (_) {
      throw const AuthException(
        'Could not send the password reset link. Please try again.',
      );
    }
  }

  Future<UserCredential> loginWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        return await _firebaseAuth.signInWithPopup(googleProvider);
      }

      final googleSignIn = GoogleSignIn.instance;
      await _initializeGoogleSignIn(googleSignIn);

      if (!googleSignIn.supportsAuthenticate()) {
        throw const AuthException(
          'Google login is not supported on this platform.',
        );
      }

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on AuthException {
      rethrow;
    } on GoogleSignInException catch (error) {
      throw AuthException(_messageForGoogleSignInCode(error.code));
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForGoogleFirebaseCode(error.code));
    } catch (_) {
      throw const AuthException(
        'Could not log in with Google. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();

      if (!kIsWeb) {
        final googleSignIn = GoogleSignIn.instance;
        await _initializeGoogleSignIn(googleSignIn);
        await googleSignIn.signOut();
      }
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForLogoutCode(error.code));
    } catch (_) {
      throw const AuthException('Could not log out. Please try again.');
    }
  }

  String _messageForFirebaseCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email and password sign up is not enabled.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Could not connect. Please check your internet connection.';
      default:
        return 'Could not create your account. Please try again.';
    }
  }

  String _messageForLoginCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Could not connect. Please check your internet connection.';
      default:
        return 'Could not log in. Please try again.';
    }
  }

  String _messageForPasswordResetCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account was found for this email address.';
      case 'too-many-requests':
        return 'Too many password reset attempts. Please try again later.';
      case 'network-request-failed':
        return 'Could not connect. Please check your internet connection.';
      default:
        return 'Could not send the password reset link. Please try again.';
    }
  }

  Future<void> _initializeGoogleSignIn(GoogleSignIn googleSignIn) async {
    if (_isGoogleSignInInitialized) {
      return;
    }

    await googleSignIn.initialize();
    _isGoogleSignInInitialized = true;
  }

  String _messageForGoogleSignInCode(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google login was cancelled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google login is not configured correctly.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google login is not available right now.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google login was interrupted. Please try again.';
      default:
        return 'Could not log in with Google. Please try again.';
    }
  }

  String _messageForGoogleFirebaseCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different login method.';
      case 'credential-already-in-use':
        return 'This Google account is already linked to another user.';
      case 'invalid-credential':
        return 'Google login credentials were invalid. Please try again.';
      case 'operation-not-allowed':
        return 'Google login is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Could not connect. Please check your internet connection.';
      default:
        return 'Could not log in with Google. Please try again.';
    }
  }

  String _messageForLogoutCode(String code) {
    switch (code) {
      case 'network-request-failed':
        return 'Could not connect. Please check your internet connection.';
      default:
        return 'Could not log out. Please try again.';
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
