import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for current user auth state
final authStateProvider = StateProvider<AuthState>((ref) => const AuthState.unauthenticated());

/// Provider for user data
final userDataProvider = StateProvider<UserData?>((ref) => null);

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.errorMessage,
  });

  const AuthState.initial() : this();

  const AuthState.authenticated({
    required String userId,
    required String email,
  })  : status = AuthStatus.authenticated,
        userId = userId,
        email = email,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        userId = null,
        email = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        userId = null,
        email = null,
        errorMessage = null;

  const AuthState.error(String errorMessage)
      : status = AuthStatus.error,
        userId = null,
        email = null,
        errorMessage = errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

class UserData {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> selectedTopics;
  final bool isGuest;
  final DateTime createdAt;

  UserData({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.selectedTopics = const [],
    this.isGuest = false,
    required this.createdAt,
  });

  UserData copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? selectedTopics,
    bool? isGuest,
    DateTime? createdAt,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

