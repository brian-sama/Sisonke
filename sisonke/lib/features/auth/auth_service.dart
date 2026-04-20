import 'package:firebase_auth/firebase_auth.dart';
import 'package:sisonke/shared/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return UserModel.guest()..id = result.user?.uid;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return UserModel(
        id: result.user?.uid,
        isGuest: false,
        displayName: result.user?.displayName,
        createdAt: result.user?.metadata.creationTime,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserModel?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return UserModel(
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

  UserModel? getCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel(
      id: firebaseUser.uid,
      isGuest: firebaseUser.isAnonymous,
      displayName: firebaseUser.displayName,
      createdAt: firebaseUser.metadata.creationTime,
    );
  }
}