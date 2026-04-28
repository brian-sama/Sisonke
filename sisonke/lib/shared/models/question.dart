import 'package:sisonke/shared/models/resource.dart';

/// Represents an anonymous question/answer
class Question {
  final String id;
  final String title;
  final String description;
  final ResourceCategory category;
  final DateTime askedAt;
  final bool isAnswered;
  final List<Answer> answers;
  final bool hasUserSaved;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.askedAt,
    this.isAnswered = false,
    this.answers = const [],
    this.hasUserSaved = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ResourceCategory.fromString(json['category'] as String),
      askedAt: DateTime.parse(json['submitted_at'] ?? json['created_at'] ?? json['asked_at'] as String),
      isAnswered: json['is_answered'] as bool? ?? false,
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      hasUserSaved: json['has_user_saved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'asked_at': askedAt.toIso8601String(),
      'is_answered': isAnswered,
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }

  Question copyWith({
    String? id,
    String? title,
    String? description,
    ResourceCategory? category,
    DateTime? askedAt,
    bool? isAnswered,
    List<Answer>? answers,
    bool? hasUserSaved,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      askedAt: askedAt ?? this.askedAt,
      isAnswered: isAnswered ?? this.isAnswered,
      answers: answers ?? this.answers,
      hasUserSaved: hasUserSaved ?? this.hasUserSaved,
    );
  }
}

/// Represents an answer to a question
class Answer {
  final String id;
  final String content;
  final String? expertName;
  final String? expertRole;
  final DateTime answeredAt;
  final int helpfulCount;
  final bool userFoundHelpful;

  Answer({
    required this.id,
    required this.content,
    this.expertName,
    this.expertRole,
    required this.answeredAt,
    this.helpfulCount = 0,
    this.userFoundHelpful = false,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String,
      content: json['content'] as String,
      expertName: json['expert_name'] as String?,
      expertRole: json['expert_role'] as String?,
      answeredAt: DateTime.parse(json['answered_at'] ?? json['created_at'] as String),
      helpfulCount: json['helpful_count'] as int? ?? 0,
      userFoundHelpful: json['user_found_helpful'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'expert_name': expertName,
      'expert_role': expertRole,
      'answered_at': answeredAt.toIso8601String(),
      'helpful_count': helpfulCount,
    };
  }

  Answer copyWith({
    String? id,
    String? content,
    String? expertName,
    String? expertRole,
    DateTime? answeredAt,
    int? helpfulCount,
    bool? userFoundHelpful,
  }) {
    return Answer(
      id: id ?? this.id,
      content: content ?? this.content,
      expertName: expertName ?? this.expertName,
      expertRole: expertRole ?? this.expertRole,
      answeredAt: answeredAt ?? this.answeredAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      userFoundHelpful: userFoundHelpful ?? this.userFoundHelpful,
    );
  }
}
