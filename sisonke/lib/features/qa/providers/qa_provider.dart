import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/qa_model.dart';
import '../services/qa_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
final qaServiceProvider = Provider<QAService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return QAService(apiService, prefs);
});

// Question List State
class QuestionListState {
  final List<Question> questions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentOffset;

  const QuestionListState({
    this.questions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentOffset = 0,
  });

  QuestionListState copyWith({
    List<Question>? questions,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentOffset,
  }) {
    return QuestionListState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

// Question List Notifier
class QuestionListNotifier extends StateNotifier<QuestionListState> {
  final QAService _qaService;
  String? _currentCategory;
  bool? _currentAnsweredFilter;

  QuestionListNotifier(this._qaService) : super(const QuestionListState());

  Future<void> loadQuestions({
    String? category,
    bool? answered,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentCategory = category;
      _currentAnsweredFilter = answered;
      state = state.copyWith(
        questions: [],
        isLoading: true,
        error: null,
        hasMore: true,
        currentOffset: 0,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    }

    try {
      final response = await _qaService.getQuestions(
        category: _currentCategory ?? category,
        answered: _currentAnsweredFilter ?? answered,
        offset: refresh ? 0 : state.currentOffset,
      );

      final newQuestions = refresh 
          ? response.questions 
          : [...state.questions, ...response.questions];

      state = state.copyWith(
        questions: newQuestions,
        isLoading: false,
        isLoadingMore: false,
        error: null,
        hasMore: response.hasMore,
        currentOffset: refresh ? response.questions.length : state.currentOffset + response.questions.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreQuestions() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _qaService.getQuestions(
        category: _currentCategory,
        answered: _currentAnsweredFilter,
        offset: state.currentOffset,
      );

      state = state.copyWith(
        questions: [...state.questions, ...response.questions],
        isLoadingMore: false,
        hasMore: response.hasMore,
        currentOffset: state.currentOffset + response.questions.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchQuestions(String query, {String? category}) async {
    await loadQuestions(refresh: true);
    // Note: This would need to be implemented in the service
    // For now, we'll load all questions and filter locally
  }

  Future<void> filterByCategory(String? category) async {
    _currentCategory = category;
    await loadQuestions(refresh: true);
  }

  Future<void> filterByAnswered(bool? answered) async {
    _currentAnsweredFilter = answered;
    await loadQuestions(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const QuestionListState();
    _currentCategory = null;
    _currentAnsweredFilter = null;
  }
}

// Single Question State
class QuestionState {
  final QuestionWithAnswers? question;
  final bool isLoading;
  final String? error;

  const QuestionState({
    this.question,
    this.isLoading = false,
    this.error,
  });

  QuestionState copyWith({
    QuestionWithAnswers? question,
    bool? isLoading,
    String? error,
  }) {
    return QuestionState(
      question: question ?? this.question,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Single Question Notifier
class QuestionNotifier extends StateNotifier<QuestionState> {
  final QAService _qaService;

  QuestionNotifier(this._qaService) : super(const QuestionState());

  Future<void> loadQuestion(String id) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final question = await _qaService.getQuestion(id);
      state = state.copyWith(
        question: question,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAnswerHelpful(String answerId) async {
    try {
      await _qaService.markAnswerHelpful(answerId);
      // Reload question to get updated helpful counts
      if (state.question != null) {
        await loadQuestion(state.question!.question.id);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> reportContent(String reason, {String? description}) async {
    if (state.question != null) {
      try {
        await _qaService.reportContent(
          id: state.question!.question.id,
          reason: reason,
          description: description,
        );
      } catch (e) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const QuestionState();
  }
}

// Submit Question State
class SubmitQuestionState {
  final bool isLoading;
  final String? error;
  final SubmittedQuestion? submittedQuestion;

  const SubmitQuestionState({
    this.isLoading = false,
    this.error,
    this.submittedQuestion,
  });

  SubmitQuestionState copyWith({
    bool? isLoading,
    String? error,
    SubmittedQuestion? submittedQuestion,
  }) {
    return SubmitQuestionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      submittedQuestion: submittedQuestion ?? this.submittedQuestion,
    );
  }
}

// Submit Question Notifier
class SubmitQuestionNotifier extends StateNotifier<SubmitQuestionState> {
  final QAService _qaService;

  SubmitQuestionNotifier(this._qaService) : super(const SubmitQuestionState());

  Future<void> submitQuestion({
    required String title,
    required String description,
    required String category,
    String? deviceId,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final submittedQuestion = await _qaService.submitQuestion(
        title: title,
        description: description,
        category: category,
        deviceId: deviceId,
      );

      state = state.copyWith(
        isLoading: false,
        submittedQuestion: submittedQuestion,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const SubmitQuestionState();
  }
}

// Categories State
class CategoriesState {
  final List<QuestionCategory> categories;
  final bool isLoading;
  final String? error;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriesState copyWith({
    List<QuestionCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Categories Notifier
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final QAService _qaService;

  CategoriesNotifier(this._qaService) : super(const CategoriesState());

  Future<void> loadCategories() async {
    if (state.isLoading || state.categories.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _qaService.getQuestionCategories();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider declarations
final questionListProvider = StateNotifierProvider<QuestionListNotifier, QuestionListState>((ref) {
  final qaService = ref.watch(qaServiceProvider);
  return QuestionListNotifier(qaService);
});

final questionProvider = StateNotifierProvider.family<QuestionNotifier, QuestionState, String>((ref, questionId) {
  final qaService = ref.watch(qaServiceProvider);
  return QuestionNotifier(qaService);
});

final submitQuestionProvider = StateNotifierProvider<SubmitQuestionNotifier, SubmitQuestionState>((ref) {
  final qaService = ref.watch(qaServiceProvider);
  return SubmitQuestionNotifier(qaService);
});

final qaCategoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final qaService = ref.watch(qaServiceProvider);
  return CategoriesNotifier(qaService);
});

// Search provider
final searchQuestionsProvider = StateNotifierProvider<QuestionListNotifier, QuestionListState>((ref) {
  final qaService = ref.watch(qaServiceProvider);
  return QuestionListNotifier(qaService);
});
