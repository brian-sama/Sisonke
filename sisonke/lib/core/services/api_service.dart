import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../exceptions/api_exception.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add JWT token to requests
          final token = await _secureStorage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh
          if (error.response?.statusCode == 401) {
            try {
              await _refreshToken();
              // Retry the original request
              final token = await _secureStorage.read(key: AppConstants.tokenKey);
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            } catch (e) {
              // Token refresh failed, clear storage
              await _secureStorage.delete(key: AppConstants.tokenKey);
              await _secureStorage.delete(key: AppConstants.userKey);
            }
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debug mode
    if (AppConstants.isDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }
  }

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];
        
        // Store token and user data
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(key: AppConstants.userKey, value: jsonEncode(user));
        
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];
        
        // Store token and user data
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(key: AppConstants.userKey, value: jsonEncode(user));
        
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createGuestSession(String deviceId) async {
    try {
      final response = await _dio.post('/auth/guest', data: {
        'deviceId': deviceId,
      });

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];
        
        // Store token and user data
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(key: AppConstants.userKey, value: jsonEncode(user));
        
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Guest session creation failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.userKey);
    } catch (e) {
      // Ignore errors during logout
    }
  }

  Future<String?> getCurrentToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: AppConstants.userKey);
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Resource methods
  Future<Map<String, dynamic>> getResources({
    String? category,
    String? search,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (language != null) queryParams['language'] = language;

      final response = await _dio.get('/resources', queryParameters: queryParams);
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch resources');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getResource(String id) async {
    try {
      final response = await _dio.get('/resources/$id');
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch resource');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> downloadResource(String id) async {
    try {
      final response = await _dio.get('/resources/$id/download');
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to download resource');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getResourceCategories() async {
    try {
      final response = await _dio.get('/resources/categories/list');
      
      if (response.data['success']) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch categories');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Q&A methods
  Future<Map<String, dynamic>> getQuestions({
    String? category,
    bool? answered,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (category != null) queryParams['category'] = category;
      if (answered != null) queryParams['answered'] = answered;

      final response = await _dio.get('/questions', queryParameters: queryParams);
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch questions');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getQuestion(String id) async {
    try {
      final response = await _dio.get('/questions/$id');
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch question');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> submitQuestion({
    required String title,
    required String description,
    required String category,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post('/questions', data: {
        'title': title,
        'description': description,
        'category': category,
        if (deviceId != null) 'deviceId': deviceId,
      });
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to submit question');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Emergency methods
  Future<Map<String, dynamic>> getEmergencyContacts() async {
    try {
      final response = await _dio.get('/emergency/contacts');
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch emergency contacts');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getEmergencyToolkit() async {
    try {
      final response = await _dio.get('/emergency/toolkit');
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch emergency toolkit');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getQuickExitContent() async {
    try {
      final response = await _dio.get('/emergency/quick-exit');
      
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to fetch quick exit content');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> syncPublicContent({String? since}) async {
    try {
      final response = await _dio.get(
        '/sync/public',
        queryParameters: {
          if (since != null && since.isNotEmpty) 'since': since,
        },
      );

      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['error'] ?? 'Failed to sync content');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> recordAnalyticsEvent({
    required String event,
    String? resourceId,
    String? category,
    Map<String, Object?>? metadata,
  }) async {
    try {
      await _dio.post('/analytics/events', data: {
        'event': event,
        if (resourceId != null) 'resourceId': resourceId,
        if (category != null) 'category': category,
        'platform': 'flutter',
        'appVersion': AppConstants.appVersion,
        if (metadata != null) 'metadata': metadata,
      });
    } on DioException {
      // Analytics must never block app workflows.
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Private methods
  Future<void> _refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      
      if (response.data['success']) {
        final token = response.data['data']['token'];
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      throw Exception('Token refresh failed');
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return const ApiException('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return const ApiException('Server response timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? 'An error occurred';
        
        switch (statusCode) {
          case 400:
            return ApiException('Bad request: $message');
          case 401:
            return const ApiException('Unauthorized. Please login again.');
          case 403:
            return const ApiException('Access denied.');
          case 404:
            return const ApiException('Resource not found.');
          case 429:
            return const ApiException('Too many requests. Please try again later.');
          case 500:
            return const ApiException('Server error. Please try again later.');
          default:
            return ApiException('Error: $message');
        }
      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.');
      case DioExceptionType.unknown:
        return const ApiException('Network error. Please check your connection.');
      default:
        return ApiException('Unexpected error: ${error.message}');
    }
  }

  // Q&A Methods
  Future<Map<String, dynamic>> markAnswerHelpful(String answerId) async {
    try {
      final response = await _dio.post('/qa/answers/$answerId/helpful');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> reportQuestion(String questionId, {required String reason, String? description}) async {
    try {
      final response = await _dio.post('/qa/questions/$questionId/report', data: {
        'reason': reason,
        'description': description,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
