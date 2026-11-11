import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-credential' ||
          error.code == 'user-not-found' ||
          error.code == 'wrong-password' ||
          error.code == 'invalid-email') {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<bool> isLoggedIn() async => _auth.currentUser != null;
}
