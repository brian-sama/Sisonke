import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sisonke/app/core/services/neon_service.dart';
import 'package:sisonke/shared/models/user.dart';

class AuthServiceNeon {
  final NeonService _neon;
  String? _currentToken;
  User? _currentUser;

  AuthServiceNeon(this._neon);

  // Get current user
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;

  /// Hash password using SHA-256 (for MVP - use bcrypt in production)
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Generate a simple JWT token (for MVP - use proper JWT library in production)
  String _generateToken(String userId) {
    final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiryTime = now + (7 * 24 * 60 * 60); // 7 days
    final payload = base64Url.encode(utf8.encode(
      '{"sub":"$userId","iat":$now,"exp":$expiryTime,"iss":"sisonke"}'
    ));
    // In production, use a real secret from environment variables
    final signature = base64Url.encode(utf8.encode('sisonke_secret_key'));
    return '$header.$payload.$signature';
  }

  /// Sign up with email and password
  Future<User> signUp(String email, String password, {String? displayName}) async {
    try {
      // Hash password
      final hashedPassword = _hashPassword(password);

      // Check if email already exists
      final existing = await _neon.query(
        'SELECT id FROM users WHERE email = \$1',
        substitutionValues: {'email': email},
      );

      if (existing.isNotEmpty) {
        throw Exception('Email already registered');
      }

      // Create user
      final results = await _neon.query(
        'INSERT INTO users (email, password_hash, is_guest, display_name) '
        'VALUES (\$1, \$2, false, \$3) RETURNING id, email, display_name, created_at',
        substitutionValues: {'email': email, 'password': hashedPassword, 'displayName': displayName},
      );

      if (results.isEmpty) throw Exception('Failed to create user');

      final userId = results.first['id'] as String;
      final token = _generateToken(userId);

      // Create session
      await _neon.execute(
        'INSERT INTO sessions (user_id, token, expires_at) '
        'VALUES (\$1, \$2, NOW() + INTERVAL \'7 days\')',
        substitutionValues: {'user_id': userId, 'token': token},
      );

      _currentToken = token;
      _currentUser = User(
        id: userId,
        isGuest: false,
        displayName: displayName ?? email,
        createdAt: DateTime.now(),
      );

      return _currentUser!;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<User> signIn(String email, String password) async {
    try {
      final hashedPassword = _hashPassword(password);

      final results = await _neon.query(
        'SELECT id, display_name, created_at FROM users '
        'WHERE email = \$1 AND password_hash = \$2 AND is_active = true',
        substitutionValues: {'email': email, 'password': hashedPassword},
      );

      if (results.isEmpty) {
        throw Exception('Invalid email or password');
      }

      final userId = results.first['id'] as String;
      final displayName = results.first['display_name'] as String?;
      final createdAt = results.first['created_at'] as DateTime?;

      final token = _generateToken(userId);

      // Create session
      await _neon.execute(
        'INSERT INTO sessions (user_id, token, expires_at) '
        'VALUES (\$1, \$2, NOW() + INTERVAL \'7 days\')',
        substitutionValues: {'user_id': userId, 'token': token},
      );

      // Update last login
      await _neon.execute(
        'UPDATE users SET last_login = NOW() WHERE id = \$1',
        substitutionValues: {'id': userId},
      );

      _currentToken = token;
      _currentUser = User(
        id: userId,
        isGuest: false,
        displayName: displayName ?? email,
        createdAt: createdAt ?? DateTime.now(),
      );

      return _currentUser!;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up as guest (anonymous user)
  Future<User> signUpGuest() async {
    try {
      final results = await _neon.query(
        'INSERT INTO users (is_guest, display_name) '
        'VALUES (true, \$1) RETURNING id, created_at',
        substitutionValues: {'display_name': 'Guest'},
      );

      if (results.isEmpty) throw Exception('Failed to create guest user');

      final userId = results.first['id'] as String;
      final token = _generateToken(userId);

      // Create session
      await _neon.execute(
        'INSERT INTO sessions (user_id, token, expires_at) '
        'VALUES (\$1, \$2, NOW() + INTERVAL \'7 days\')',
        substitutionValues: {'user_id': userId, 'token': token},
      );

      _currentToken = token;
      _currentUser = User(
        id: userId,
        isGuest: true,
        displayName: 'Guest',
        createdAt: DateTime.now(),
      );

      return _currentUser!;
    } catch (e) {
      throw Exception('Guest sign up failed: $e');
    }
  }

  /// Validate and restore session from token
  Future<bool> restoreSession(String token) async {
    try {
      final results = await _neon.query(
        'SELECT u.id, u.email, u.display_name, u.is_guest, u.created_at, s.expires_at '
        'FROM sessions s JOIN users u ON s.user_id = u.id '
        'WHERE s.token = \$1 AND s.expires_at > NOW()',
        substitutionValues: {'token': token},
      );

      if (results.isEmpty) {
        throw Exception('Session expired or invalid');
      }

      final row = results.first;
      final userId = row['id'] as String;
      final email = row['email'] as String?;
      final displayName = row['display_name'] as String?;
      final isGuest = row['is_guest'] as bool;
      final createdAt = row['created_at'] as DateTime?;

      // Update last_used
      await _neon.execute(
        'UPDATE sessions SET last_used = NOW() WHERE token = \$1',
        substitutionValues: {'token': token},
      );

      _currentToken = token;
      _currentUser = User(
        id: userId,
        isGuest: isGuest,
        displayName: displayName ?? email ?? 'Guest',
        createdAt: createdAt ?? DateTime.now(),
      );

      return true;
    } catch (e) {
      print('Session restore failed: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (_currentToken != null) {
        await _neon.execute(
          'DELETE FROM sessions WHERE token = \$1',
          substitutionValues: {'token': _currentToken},
        );
      }
      _currentToken = null;
      _currentUser = null;
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');

      final oldHash = _hashPassword(oldPassword);
      final newHash = _hashPassword(newPassword);

      // Verify old password
      final verify = await _neon.query(
        'SELECT id FROM users WHERE id = \$1 AND password_hash = \$2',
        substitutionValues: {'id': _currentUser!.id, 'password': oldHash},
      );

      if (verify.isEmpty) throw Exception('Current password is incorrect');

      // Update password
      await _neon.execute(
        'UPDATE users SET password_hash = \$1 WHERE id = \$2',
        substitutionValues: {'password': newHash, 'id': _currentUser!.id},
      );
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String password) async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');

      final hashedPassword = _hashPassword(password);

      // Verify password
      final verify = await _neon.query(
        'SELECT id FROM users WHERE id = \$1 AND password_hash = \$2',
        substitutionValues: {'id': _currentUser!.id, 'password': hashedPassword},
      );

      if (verify.isEmpty) throw Exception('Password is incorrect');

      // Delete user (cascade will delete sessions and data)
      await _neon.execute(
        'DELETE FROM users WHERE id = \$1',
        substitutionValues: {'id': _currentUser!.id},
      );

      await signOut();
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
}