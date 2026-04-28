import '../models/qa_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QAService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  QAService(this._apiService, this._prefs);

  // Get questions with caching
  Future<QuestionListResponse> getQuestions({
    String? category,
    bool? answered,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(category, answered, limit, offset);
    
    // Try to get from cache first
    if (!forceRefresh) {
      final cached = _getCachedQuestions(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from API
    try {
      final response = await _apiService.getQuestions(
        category: category,
        answered: answered,
        limit: limit,
        offset: offset,
      );

      final questionList = QuestionListResponse.fromJson(response);
      
      // Cache the response
      await _cacheQuestions(cacheKey, questionList);
      
      return questionList;
    } catch (e) {
      // If API fails, try to return stale cache
      final cached = _getCachedQuestions(cacheKey);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  // Get single question with answers
  Future<QuestionWithAnswers> getQuestion(String id, {bool forceRefresh = false}) async {
    final cacheKey = 'question_$id';
    
    // Try cache first
    if (!forceRefresh) {
      final cached = _getCachedQuestion(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final response = await _apiService.getQuestion(id);
      final question = QuestionWithAnswers.fromJson(response);
      
      // Cache the question
      await _cacheQuestion(cacheKey, question);
      
      return question;
    } catch (e) {
      // Return stale cache if available
      final cached = _getCachedQuestion(cacheKey);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  // Submit new question
  Future<SubmittedQuestion> submitQuestion({
    required String title,
    required String description,
    required String category,
    String? deviceId,
  }) async {
    try {
      final response = await _apiService.submitQuestion(
        title: title,
        description: description,
        category: category,
        deviceId: deviceId,
      );
      
      final submittedQuestion = SubmittedQuestion.fromJson(response);
      
      // Clear relevant cache
      await _clearQuestionsCache();
      
      return submittedQuestion;
    } catch (e) {
      rethrow;
    }
  }

  // Mark answer as helpful
  Future<void> markAnswerHelpful(String answerId) async {
    try {
      await _apiService.markAnswerHelpful(answerId);
      
      // Clear cache to force refresh
      await _clearQuestionsCache();
    } catch (e) {
      rethrow;
    }
  }

  // Report question or answer
  Future<void> reportContent({
    required String id,
    required String reason,
    String? description,
  }) async {
    try {
      await _apiService.reportQuestion(id, reason: reason, description: description);
    } catch (e) {
      rethrow;
    }
  }

  // Get question categories
  Future<List<QuestionCategory>> getQuestionCategories() async {
    final cacheKey = 'question_categories';
    
    // Try cache first
    final cached = _getCachedCategories(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final response = await _apiService.getResourceCategories(); // Reuse endpoint
      final categories = response
          .map((json) => QuestionCategory.fromJson(json))
          .where((cat) => AppConstants.questionCategories.contains(cat.id))
          .toList();
      
      // Cache categories
      await _cacheCategories(cacheKey, categories);
      
      return categories;
    } catch (e) {
      rethrow;
    }
  }

  // Search questions
  Future<QuestionListResponse> searchQuestions(
    String query, {
    String? category,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
  }) async {
    return getQuestions(
      category: category,
      limit: limit,
      offset: offset,
      forceRefresh: true, // Always refresh for search
    );
  }

  // Get user's submitted questions (if authenticated)
  Future<List<SubmittedQuestion>> getUserQuestions() async {
    // This would require additional backend endpoint
    // For now, return empty list
    return [];
  }

  // Private cache methods
  QuestionListResponse? _getCachedQuestions(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        // Check if cache is still valid
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          return QuestionListResponse.fromJson(cachedData['data']);
        }
        
        // Remove expired cache
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  Future<void> _cacheQuestions(String cacheKey, QuestionListResponse questions) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': questions.toJson(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  QuestionWithAnswers? _getCachedQuestion(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          return QuestionWithAnswers.fromJson(cachedData['data']);
        }
        
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  Future<void> _cacheQuestion(String cacheKey, QuestionWithAnswers question) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': question.toJson(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  List<QuestionCategory>? _getCachedCategories(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          final List<dynamic> categoriesList = cachedData['data'];
          return categoriesList
              .map((json) => QuestionCategory.fromJson(json))
              .toList();
        }
        
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  Future<void> _cacheCategories(String cacheKey, List<QuestionCategory> categories) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': categories.map((c) => c.toJson()).toList(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<void> _clearQuestionsCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('questions_') || key.startsWith('question_')) {
        await _prefs.remove(key);
      }
    }
  }

  String _generateCacheKey(
    String? category,
    bool? answered,
    int limit,
    int offset,
  ) {
    final parts = ['questions'];
    if (category != null) parts.add(category);
    if (answered != null) parts.add(answered.toString());
    parts.add(limit.toString());
    parts.add(offset.toString());
    return parts.join('_');
  }

  // Clear all cache
  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('questions_') || key.startsWith('question_')) {
        await _prefs.remove(key);
      }
    }
  }
}
