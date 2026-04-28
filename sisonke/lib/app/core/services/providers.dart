import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/app/core/services/local_database_service.dart';
import 'package:sisonke/app/core/services/neon_service.dart';
import 'package:sisonke/app/core/services/security_service.dart';
import 'package:sisonke/features/auth/auth_service_neon.dart';
import 'package:sisonke/shared/models/user.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  throw UnimplementedError('LocalDatabaseService must be overridden in main.dart');
});

final neonServiceProvider = Provider<NeonService>((ref) {
  return NeonService();
});

final authServiceProvider = Provider<AuthServiceNeon>((ref) {
  final neonService = ref.watch(neonServiceProvider);
  return AuthServiceNeon(neonService);
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

class AuthStateNotifier extends StateNotifier<User?> {
  final AuthServiceNeon _authService;

  AuthStateNotifier(this._authService) : super(null) {
    _initializeCurrentUser();
  }

  void _initializeCurrentUser() {
    state = _authService.currentUser;
  }

  Future<void> signUp(String email, String password, {String? displayName}) async {
    state = await _authService.signUp(email, password, displayName: displayName);
  }

  Future<void> signIn(String email, String password) async {
    state = await _authService.signIn(email, password);
  }

  Future<void> signUpGuest() async {
    state = await _authService.signUpGuest();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }

  Future<bool> restoreSession(String token) async {
    final success = await _authService.restoreSession(token);
    if (success) {
      state = _authService.currentUser;
    }
    return success;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _authService.changePassword(oldPassword, newPassword);
  }

  Future<void> deleteAccount(String password) async {
    await _authService.deleteAccount(password);
    state = null;
  }

  String? get currentToken => _authService.currentToken;
}