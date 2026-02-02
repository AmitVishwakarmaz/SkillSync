/// Authentication service using Firebase Auth
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _setLoading(false);
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return null;
    } catch (e) {
      _setError('Failed to sign in with Google');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
