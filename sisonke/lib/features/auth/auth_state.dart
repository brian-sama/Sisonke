import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/features/auth/auth_service.dart';
import 'package:sisonke/shared/models/user.dart';

class AuthState extends StateNotifier<UserModel?> {
  final AuthService _authService;

  AuthState(this._authService) : super(null) {
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        state = UserModel(
          id: firebaseUser.uid,
          isGuest: firebaseUser.isAnonymous,
          displayName: firebaseUser.displayName,
          createdAt: firebaseUser.metadata.creationTime,
        );
      } else {
        state = null;
      }
    });
  }

  Future<void> signInAnonymously() async {
    state = await _authService.signInAnonymously();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = await _authService.signInWithEmail(email, password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = await _authService.signUpWithEmail(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }
}

final authStateProvider = StateNotifierProvider<AuthState, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthState(authService);
});