import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/app/core/services/neon_service.dart';
import 'package:sisonke/features/auth/auth_service.dart';
import 'package:sisonke/features/auth/auth_state.dart';

final neonServiceProvider = Provider<NeonService>((ref) {
  return NeonService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StateNotifierProvider<AuthState, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthState(authService);
});