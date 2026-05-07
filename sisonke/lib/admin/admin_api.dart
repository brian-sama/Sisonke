import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminApi {
  static const _tokenKey = 'admin_token';
  static const _userKey = 'admin_user';
  final Dio _dio;
  final SharedPreferences _prefs;

  AdminApi(this._prefs)
    : _dio = Dio(
        BaseOptions(
          baseUrl: _adminApiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static String get _adminApiBaseUrl {
    return AppConstants.apiBaseUrl;
  }

  bool get isAuthenticated => (_prefs.getString(_tokenKey) ?? '').isNotEmpty;

  Map<String, dynamic>? get currentUser {
    final raw = _prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(_decode(raw));
    } catch (_) {
      return null;
    }
  }

  List<String> get currentRoles {
    final user = currentUser;
    final roles = user?['roles'];
    if (roles is List)
      return roles.map((item) => _normalizeRole('$item')).toList();
    return [_normalizeRole('${user?['role'] ?? ''}')];
  }

  Future<void> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final roles = _rolesFor(user);
    const allowedRoles = [
      'admin',
      'system-admin',
      'super-admin',
      'counselor',
      'moderator',
      'content-admin',
      'content-manager',
      'safety-reviewer',
      'analyst',
    ];
    if (!roles.any(allowedRoles.contains)) {
      throw Exception('You do not have dashboard access.');
    }
    await _prefs.setString(_tokenKey, data['token'] as String);
    await _prefs.setString(_userKey, _encode(user));
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  static List<String> _rolesFor(Map<String, dynamic> user) {
    final roles = user['roles'];
    if (roles is List)
      return roles.map((item) => _normalizeRole('$item')).toList();
    return [_normalizeRole('${user['role'] ?? ''}')];
  }

  static String _normalizeRole(String value) =>
      value.trim().toLowerCase().replaceAll('_', '-');

  static String _encode(Map<String, dynamic> value) => jsonEncode(value);

  static Map<String, dynamic> _decode(String value) {
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }

  Future<Map<String, dynamic>> overview() async {
    final response = await _dio.get('/admin/overview');
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> analytics({int days = 30}) async {
    final response = await _dio.get(
      '/admin/analytics',
      queryParameters: {'days': days},
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<List<Map<String, dynamic>>> resources() async {
    final response = await _dio.get('/admin/resources');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> saveResource(Map<String, dynamic> payload, {String? id}) async {
    if (id == null) {
      await _dio.post('/admin/resources', data: payload);
    } else {
      await _dio.put('/admin/resources/$id', data: payload);
    }
  }

  Future<void> publishResource(String id) async {
    await _dio.post('/admin/resources/$id/publish');
  }

  Future<void> archiveResource(String id) async {
    await _dio.post('/admin/resources/$id/archive');
  }

  Future<List<Map<String, dynamic>>> emergencyContacts() async {
    final response = await _dio.get('/admin/emergency-contacts');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> saveEmergencyContact(
    Map<String, dynamic> payload, {
    String? id,
  }) async {
    if (id == null) {
      await _dio.post('/admin/emergency-contacts', data: payload);
    } else {
      await _dio.put('/admin/emergency-contacts/$id', data: payload);
    }
  }

  Future<List<Map<String, dynamic>>> counselorCases() async {
    final response = await _dio.get('/admin/counselor-cases');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> counselorOperations() async {
    final response = await _dio.get('/admin/counselor-operations');
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<void> assignCounselorCase(String id, String counselorId) async {
    await _dio.post(
      '/admin/counselor-cases/$id/assign',
      data: {'counselorId': counselorId},
    );
  }

  Future<void> setCounselorAvailability(
    String id, {
    required String status,
    required bool isOnCall,
    List<String> specializations = const [],
  }) async {
    await _dio.post(
      '/admin/counselors/$id/availability',
      data: {
        'status': status,
        'isOnCall': isOnCall,
        'specializations': specializations,
      },
    );
  }

  Future<void> updateCounselorCaseStatus(String id, String status) async {
    await _dio.post(
      '/admin/counselor-cases/$id/status',
      data: {'status': status},
    );
  }

  Future<void> addCounselorNote(String id, String note) async {
    await _dio.post('/admin/counselor-cases/$id/notes', data: {'note': note});
  }

  Future<List<Map<String, dynamic>>> counselorCaseMessages(String caseId) async {
    final response = await _dio.get('/admin/counselor-cases/$caseId/messages');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> communityPosts() async {
    final response = await _dio.get('/admin/community-posts');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> moderateCommunityPost(
    String id,
    String status, {
    String? reason,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (reason != null) data['reason'] = reason;
    await _dio.post('/admin/community-posts/$id/moderate', data: data);
  }

  Future<List<Map<String, dynamic>>> reports() async {
    final response = await _dio.get('/admin/reports');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> updateReportStatus(String id, String status) async {
    await _dio.post('/admin/reports/$id/status', data: {'status': status});
  }

  Future<List<Map<String, dynamic>>> cmsContent() async {
    final response = await _dio.get('/admin/cms-content');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> createCmsContent(Map<String, dynamic> payload) async {
    await _dio.post('/admin/cms-content', data: payload);
  }

  Future<void> saveCmsContent(
    Map<String, dynamic> payload, {
    String? id,
  }) async {
    if (id == null) {
      await _dio.post('/admin/cms-content', data: payload);
    } else {
      await _dio.put('/admin/cms-content/$id', data: payload);
    }
  }

  Future<List<Map<String, dynamic>>> users() async {
    final response = await _dio.get('/admin/users');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> setUserSuspension(
    String id,
    bool suspended, {
    String? reason,
  }) async {
    final data = <String, dynamic>{'suspended': suspended};
    if (reason != null) data['reason'] = reason;
    await _dio.post('/admin/users/$id/suspension', data: data);
  }

  Future<List<Map<String, dynamic>>> securityLogs() async {
    final response = await _dio.get('/admin/security-logs');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
