import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sisonke/shared/models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return User.guest().copyWith(id: result.user?.uid);
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return User(
        id: result.user?.uid,
        isGuest: false,
        displayName: result.user?.displayName,
        createdAt: result.user?.metadata.creationTime,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return User(
        id: result.user?.uid,
        isGuest: false,
        displayName: result.user?.displayName,
        createdAt: result.user?.metadata.creationTime,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return User(
      id: firebaseUser.uid,
      isGuest: firebaseUser.isAnonymous,
      displayName: firebaseUser.displayName,
      createdAt: firebaseUser.metadata.creationTime,
    );
  }
}
