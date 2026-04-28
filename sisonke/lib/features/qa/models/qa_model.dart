class Question {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime submittedAt;
  final bool isAnswered;
  final bool isPublished;
  final bool flaggedForUrgent;
  final int viewCount;
  final int helpfulCount;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.submittedAt,
    this.isAnswered = false,
    this.isPublished = false,
    this.flaggedForUrgent = false,
    this.viewCount = 0,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      isAnswered: json['is_answered'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      flaggedForUrgent: json['flagged_for_urgent'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'submitted_at': submittedAt.toIso8601String(),
      'is_answered': isAnswered,
      'is_published': isPublished,
      'flagged_for_urgent': flaggedForUrgent,
      'view_count': viewCount,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Question copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? submittedAt,
    bool? isAnswered,
    bool? isPublished,
    bool? flaggedForUrgent,
    int? viewCount,
    int? helpfulCount,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      submittedAt: submittedAt ?? this.submittedAt,
      isAnswered: isAnswered ?? this.isAnswered,
      isPublished: isPublished ?? this.isPublished,
      flaggedForUrgent: flaggedForUrgent ?? this.flaggedForUrgent,
      viewCount: viewCount ?? this.viewCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Answer {
  final String id;
  final String questionId;
  final String content;
  final String? expertName;
  final String? expertRole;
  final DateTime answeredAt;
  final int helpfulCount;
  final bool isPublished;
  final DateTime createdAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.content,
    this.expertName,
    this.expertRole,
    required this.answeredAt,
    this.helpfulCount = 0,
    this.isPublished = false,
    required this.createdAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      content: json['content'] as String,
      expertName: json['expert_name'] as String?,
      expertRole: json['expert_role'] as String?,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      helpfulCount: json['helpful_count'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'content': content,
      'expert_name': expertName,
      'expert_role': expertRole,
      'answered_at': answeredAt.toIso8601String(),
      'helpful_count': helpfulCount,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Answer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class QuestionWithAnswers {
  final Question question;
  final List<Answer> answers;

  QuestionWithAnswers({
    required this.question,
    required this.answers,
  });

  factory QuestionWithAnswers.fromJson(Map<String, dynamic> json) {
    return QuestionWithAnswers(
      question: Question.fromJson(json),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...question.toJson(),
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class QuestionListResponse {
  final List<Question> questions;
  final int total;
  final bool hasMore;

  QuestionListResponse({
    required this.questions,
    required this.total,
    required this.hasMore,
  });

  factory QuestionListResponse.fromJson(Map<String, dynamic> json) {
    return QuestionListResponse(
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'total': total,
      'hasMore': hasMore,
    };
  }
}

class SubmittedQuestion {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool flaggedForUrgent;
  final String? message;
  final DateTime submittedAt;

  SubmittedQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.flaggedForUrgent = false,
    this.message,
    required this.submittedAt,
  });

  factory SubmittedQuestion.fromJson(Map<String, dynamic> json) {
    return SubmittedQuestion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      flaggedForUrgent: json['flaggedForUrgent'] as bool? ?? false,
      message: json['message'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'flagged_for_urgent': flaggedForUrgent,
      'message': message,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }
}

class QuestionCategory {
  final String id;
  final String name;
  final String description;

  QuestionCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory QuestionCategory.fromJson(Map<String, dynamic> json) {
    return QuestionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
