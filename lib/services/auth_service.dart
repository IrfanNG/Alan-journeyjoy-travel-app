import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthResult {
  final String? uid;
  final String? error;
  final bool isEmailConflict;
  AuthResult({this.uid, this.error, this.isEmailConflict = false});
  bool get isSuccess => uid != null && error == null;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return AuthResult(uid: cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException code: ${e.code}');
      debugPrint('FirebaseAuthException message: ${e.message}');
      debugPrint('FirebaseAuthException plugin: ${e.plugin}');
      if (e.code == 'email-already-in-use') {
        return AuthResult(
          error: 'Email already registered. Please login instead.',
          isEmailConflict: true,
        );
      }
      return AuthResult(error: _mapAuthError(e.code));
    } catch (e) {
      return AuthResult(error: 'Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _ensureUserDoc(cred.user!);
      return AuthResult(uid: cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      return AuthResult(error: _mapAuthError(e.code));
    } catch (e) {
      return AuthResult(error: 'Something went wrong. Please try again.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> ensureUserDocExists(User user) async {
    try {
      await _ensureUserDoc(user);
    } catch (_) {
      // Silently fail; next sync cycle will retry.
    }
  }

  Future<void> _ensureUserDoc(User user) async {
    try {
      final ref = _firestore.collection('users').doc(user.uid);
      final snapshot = await ref.get();
      final now = FieldValue.serverTimestamp();
      if (snapshot.exists) {
        await ref.set({'updatedAt': now}, SetOptions(merge: true));
      } else {
        await ref.set({
          'name': user.displayName ?? user.email?.split('@').first ?? 'User',
          if (user.email != null) 'email': user.email,
          'createdAt': now,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // Silently fail.
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'internal-error':
        return 'Firebase registration failed. Check Firebase Auth setup.';
      default:
        return code;
    }
  }
}
