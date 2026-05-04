import 'package:dio/dio.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminApi {
  static const _tokenKey = 'admin_token';
  final Dio _dio;
  final SharedPreferences _prefs;

  AdminApi(this._prefs)
      : _dio = Dio(BaseOptions(
          baseUrl: _adminApiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _prefs.getString(_tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static String get _adminApiBaseUrl {
    return AppConstants.apiBaseUrl;
  }

  bool get isAuthenticated => (_prefs.getString(_tokenKey) ?? '').isNotEmpty;

  Future<void> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    if (user['role'] != 'admin') {
      throw Exception('This account does not have admin access.');
    }
    await _prefs.setString(_tokenKey, data['token'] as String);
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> overview() async {
    final response = await _dio.get('/admin/overview');
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> analytics({int days = 30}) async {
    final response = await _dio.get('/admin/analytics', queryParameters: {'days': days});
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

  Future<void> saveEmergencyContact(Map<String, dynamic> payload, {String? id}) async {
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

  Future<void> updateCounselorCaseStatus(String id, String status) async {
    await _dio.post('/admin/counselor-cases/$id/status', data: {'status': status});
  }

  Future<void> addCounselorNote(String id, String note) async {
    await _dio.post('/admin/counselor-cases/$id/notes', data: {'note': note});
  }

  Future<List<Map<String, dynamic>>> communityPosts() async {
    final response = await _dio.get('/admin/community-posts');
    return (response.data['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> moderateCommunityPost(String id, String status, {String? reason}) async {
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

  Future<void> saveCmsContent(Map<String, dynamic> payload, {String? id}) async {
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

  Future<void> setUserSuspension(String id, bool suspended, {String? reason}) async {
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
