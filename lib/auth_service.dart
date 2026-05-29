import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static bool get _isReady => Firebase.apps.isNotEmpty;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static User? get currentUser => _isReady ? _auth.currentUser : null;
  static Stream<User?> get authStateChanges =>
      _isReady ? _auth.authStateChanges() : const Stream.empty();

  static Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!_isReady) {
      throw Exception(
          'Firebase config missing. Run flutterfire configure first.');
    }
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    if (!_isReady) {
      throw Exception(
          'Firebase config missing. Run flutterfire configure first.');
    }
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> sendPasswordReset(String email) {
    if (!_isReady) {
      throw Exception(
          'Firebase config missing. Run flutterfire configure first.');
    }
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> updateDisplayName(String name) async {
    if (!_isReady) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final trimmed = name.trim();
    if (trimmed.isEmpty || user.displayName == trimmed) return;

    await user.updateDisplayName(trimmed);
    await user.reload();
  }

  static Future<void> signOut() => _isReady ? _auth.signOut() : Future.value();
}
