import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../exceptions/api_exception.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

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
              final token = await _secureStorage.read(
                key: AppConstants.tokenKey,
              );
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
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }
  }

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];

        // Store token and user data
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(
          key: AppConstants.userKey,
          value: jsonEncode(user),
        );

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
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password},
      );

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];

        // Store token and user data
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(
          key: AppConstants.userKey,
          value: jsonEncode(user),
        );

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
      final response = await _dio.post(
        '/auth/guest',
        data: {'deviceId': deviceId},
      );

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];

        // Store token and user data
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(
          key: AppConstants.userKey,
          value: jsonEncode(user),
        );

        return response.data['data'];
      } else {
        throw ApiException(
          response.data['error'] ?? 'Guest session creation failed',
        );
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

  Future<bool> get isAuthenticated async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
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

  bool userHasRole(Map<String, dynamic>? user, String role) {
    if (user == null) return false;
    final normalized = role.trim().toLowerCase().replaceAll('_', '-');
    final roles = user['roles'];
    if (roles is List) {
      return roles
          .map((item) => '$item'.trim().toLowerCase().replaceAll('_', '-'))
          .contains(normalized);
    }
    return '${user['role']}'.trim().toLowerCase().replaceAll('_', '-') ==
        normalized;
  }

  Future<void> ensureGuestSession() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) return;

    var deviceId = await _secureStorage.read(key: AppConstants.deviceIdKey);
    if (deviceId == null || deviceId.length < 10) {
      final suffix = Random.secure().nextInt(0x7FFFFFFF).toRadixString(16);
      deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}-$suffix';
      await _secureStorage.write(
        key: AppConstants.deviceIdKey,
        value: deviceId,
      );
    }

    await createGuestSession(deviceId);
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
      final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (language != null) queryParams['language'] = language;

      final response = await _dio.get(
        '/resources',
        queryParameters: queryParams,
      );

      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch resources',
        );
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
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch resource',
        );
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
        throw ApiException(
          response.data['error'] ?? 'Failed to download resource',
        );
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
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch categories',
        );
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
      final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (category != null) queryParams['category'] = category;
      if (answered != null) queryParams['answered'] = answered;

      final response = await _dio.get(
        '/questions',
        queryParameters: queryParams,
      );

      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch questions',
        );
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
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch question',
        );
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
      final response = await _dio.post(
        '/questions',
        data: {
          'title': title,
          'description': description,
          'category': category,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );

      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw ApiException(
          response.data['error'] ?? 'Failed to submit question',
        );
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
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch emergency contacts',
        );
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
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch emergency toolkit',
        );
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
        throw ApiException(
          response.data['error'] ?? 'Failed to fetch quick exit content',
        );
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
      await _dio.post(
        '/analytics/events',
        data: {
          'event': event,
          if (resourceId != null) 'resourceId': resourceId,
          if (category != null) 'category': category,
          'platform': 'flutter',
          'appVersion': AppConstants.appVersion,
          if (metadata != null) 'metadata': metadata,
        },
      );
    } on DioException {
      // Analytics must never block app workflows.
    }
  }

  Future<Map<String, dynamic>> sendChatbotMessage({
    required String message,
    required String persona,
    String? sessionId,
    String? deviceId,
  }) async {
    try {
      final payload = <String, dynamic>{'message': message, 'persona': persona};
      if (sessionId != null) payload['sessionId'] = sessionId;
      if (deviceId != null) payload['deviceId'] = deviceId;

      final response = await _dio.post('/chatbot/message', data: payload);

      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      } else {
        throw ApiException(response.data['error'] ?? 'Chatbot request failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> saveOnboardingProfile({
    required String nickname,
    required int age,
    required String gender,
    required String location,
    required String chatbotPersona,
    required Map<String, bool> screeningAnswers,
    bool pinEnabled = true,
    bool biometricEnabled = false,
    int autoLockMinutes = 5,
    bool hideJournalPreview = true,
    bool consentAccepted = true,
  }) async {
    await ensureGuestSession();
    try {
      final response = await _dio.put(
        '/profiles/me',
        data: {
          'nickname': nickname,
          'age': age,
          'gender': gender,
          'location': location,
          'consentAccepted': consentAccepted,
          'pinEnabled': pinEnabled,
          'biometricEnabled': biometricEnabled,
          'autoLockMinutes': autoLockMinutes,
          'hideJournalPreview': hideJournalPreview,
          'chatbotPersona': chatbotPersona,
          'screeningAnswers': screeningAnswers,
        },
      );

      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Profile save failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    await ensureGuestSession();
    try {
      final response = await _dio.get('/profiles/me');
      if (response.data['success']) {
        final data = response.data['data'];
        return data == null ? null : Map<String, dynamic>.from(data as Map);
      }
      throw ApiException(response.data['error'] ?? 'Profile load failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateSafetySettings({
    required bool pinEnabled,
    required bool biometricEnabled,
    required int autoLockMinutes,
    required bool hideJournalPreview,
  }) async {
    await ensureGuestSession();
    try {
      final response = await _dio.patch(
        '/profiles/me/safety',
        data: {
          'pinEnabled': pinEnabled,
          'biometricEnabled': biometricEnabled,
          'autoLockMinutes': autoLockMinutes,
          'hideJournalPreview': hideJournalPreview,
        },
      );

      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(
        response.data['error'] ?? 'Safety settings save failed',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> requestCounselor({
    required String issueCategory,
    String? summary,
    String riskLevel = 'medium',
    String preferredContactMethod = 'live_chat',
    String? callbackPhone,
  }) async {
    await ensureGuestSession();
    try {
      final data = <String, dynamic>{
        'issueCategory': issueCategory,
        'riskLevel': riskLevel,
        'preferredContactMethod': preferredContactMethod,
        if (callbackPhone != null && callbackPhone.trim().isNotEmpty)
          'callbackPhone': callbackPhone.trim(),
      };
      if (summary != null && summary.trim().isNotEmpty) {
        data['summary'] = summary.trim();
      }

      final response = await _dio.post('/counselor/requests', data: data);
      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Counselor request failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyCounselorCases() async {
    await ensureGuestSession();
    try {
      final response = await _dio.get('/counselor/my-cases');
      if (response.data['success']) {
        return (response.data['data'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      throw ApiException(response.data['error'] ?? 'Counselor cases failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCounselorCase(String caseId) async {
    await ensureGuestSession();
    try {
      final response = await _dio.get('/counselor/my-cases/$caseId');
      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Counselor case failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> sendCaseMessage({
    required String caseId,
    required String content,
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    await ensureGuestSession();
    try {
      final response = await _dio.post(
        '/counselor/cases/$caseId/messages',
        data: {
          'content': content,
          'messageType': messageType,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
        },
      );
      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Case message failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> requestCaseCallback({
    required String caseId,
    required String callbackPhone,
  }) async {
    await ensureGuestSession();
    try {
      final response = await _dio.post(
        '/counselor/cases/$caseId/callback',
        data: {'callbackPhone': callbackPhone},
      );
      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Callback request failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAssignedCounselorCases() async {
    try {
      final response = await _dio.get('/counselor/cases');
      if (response.data['success']) {
        return (response.data['data'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      throw ApiException(response.data['error'] ?? 'Assigned cases failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateCounselorCaseStatus({
    required String caseId,
    required String status,
  }) async {
    try {
      final response = await _dio.post(
        '/counselor/cases/$caseId/status',
        data: {'status': status},
      );
      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Case status failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> addCounselorCaseNote({
    required String caseId,
    required String note,
  }) async {
    try {
      final response = await _dio.post(
        '/counselor/cases/$caseId/notes',
        data: {'note': note},
      );
      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Case note failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> setMyCounselorAvailability({
    required String status,
    bool isOnCall = false,
  }) async {
    try {
      await _dio.post(
        '/counselor/me/availability',
        data: {'status': status, 'isOnCall': isOnCall},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    await ensureGuestSession();
    try {
      await _dio.post(
        '/notifications/push-token',
        data: {'token': token, 'platform': platform},
      );
    } on DioException {
      // Push token sync should never block app startup or support flows.
    }
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts({
    required String ageGroup,
  }) async {
    await ensureGuestSession();
    try {
      final response = await _dio.get(
        '/community/posts',
        queryParameters: {'ageGroup': ageGroup},
      );
      if (response.data['success']) {
        return (response.data['data'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      throw ApiException(response.data['error'] ?? 'Community feed failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> submitCommunityPost({
    required String ageGroup,
    required String content,
  }) async {
    await ensureGuestSession();
    try {
      final response = await _dio.post(
        '/community/posts',
        data: {'ageGroup': ageGroup, 'content': content},
      );
      if (response.data['success']) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw ApiException(response.data['error'] ?? 'Community post failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
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
        return const ApiException(
          'Connection timeout. Please check your internet connection.',
        );
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
            return const ApiException(
              'Too many requests. Please try again later.',
            );
          case 500:
            return const ApiException('Server error. Please try again later.');
          default:
            return ApiException('Error: $message');
        }
      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.');
      case DioExceptionType.unknown:
        return const ApiException(
          'Network error. Please check your connection.',
        );
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

  Future<Map<String, dynamic>> reportQuestion(
    String questionId, {
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/qa/questions/$questionId/report',
        data: {'reason': reason, 'description': description},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
