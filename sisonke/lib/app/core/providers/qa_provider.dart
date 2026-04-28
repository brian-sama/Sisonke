import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/models/index.dart';

/// Provider for questions
final questionsProvider = StateProvider<List<Question>>((ref) => []);

/// Provider for question detail
final questionDetailProvider =
    StateProvider.family<Question?, String>((ref, questionId) {
  final questions = ref.watch(questionsProvider);
  try {
    return questions.firstWhere((q) => q.id == questionId);
  } catch (e) {
    return null;
  }
});

/// Provider for category filter
final qaFilterProvider = StateProvider<ResourceCategory?>((ref) => null);

/// Provider for filtered questions
final filteredQuestionsProvider = StateProvider<List<Question>>((ref) {
  final questions = ref.watch(questionsProvider);
  final category = ref.watch(qaFilterProvider);

  if (category == null) {
    return questions;
  }

  return questions.where((q) => q.category == category).toList();
});

/// Provider for answered questions only
final answeredQuestionsProvider = StateProvider<List<Question>>((ref) {
  final questions = ref.watch(filteredQuestionsProvider);
  return questions.where((q) => q.isAnswered).toList();
});

/// Provider for saved answers
final savedAnswersProvider = StateProvider<List<String>>((ref) => []);

