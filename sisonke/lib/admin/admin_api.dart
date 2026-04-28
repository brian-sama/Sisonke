import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminApi {
  static const _tokenKey = 'admin_token';
  final Dio _dio;
  final SharedPreferences _prefs;

  AdminApi(this._prefs)
      : _dio = Dio(BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://sisonke.mmpzmne.co.zw/api',
          ),
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
}
