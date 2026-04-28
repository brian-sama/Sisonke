
/// Represents a resource (article, guide, tool)
class Resource {
  final String id;
  final String title;
  final String description;
  final String? content;
  final ResourceCategory category;
  final List<String> tags;
  final String? authorId;
  final String? authorName;
  final String? imageUrl;
  final int? readingTimeMinutes;
  final String language;
  final bool isPublished;
  final bool isOfflineAvailable;
  final int viewCount;
  final int downloadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSaved; // Local UI state

  Resource({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    required this.category,
    this.tags = const [],
    this.authorId,
    this.authorName,
    this.imageUrl,
    this.readingTimeMinutes,
    this.language = 'en',
    this.isPublished = true,
    this.isOfflineAvailable = false,
    this.viewCount = 0,
    this.downloadCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isSaved = false,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String?,
      category: ResourceCategory.fromString(json['category'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      authorId: json['author_id'] as String? ?? json['authorId'],
      authorName: json['author_name'] as String? ?? json['authorName'],
      imageUrl: json['image_url'] as String? ?? json['imageUrl'],
      readingTimeMinutes: json['reading_time_minutes'] as int? ?? json['readingTimeMinutes'],
      language: json['language'] as String? ?? 'en',
      isPublished: json['is_published'] as bool? ?? json['isPublished'] ?? true,
      isOfflineAvailable: json['is_offline_available'] as bool? ?? json['isOfflineAvailable'] ?? false,
      viewCount: json['view_count'] as int? ?? json['viewCount'] ?? 0,
      downloadCount: json['download_count'] as int? ?? json['downloadCount'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category.name,
      'tags': tags,
      'author_id': authorId,
      'author_name': authorName,
      'image_url': imageUrl,
      'reading_time_minutes': readingTimeMinutes,
      'language': language,
      'is_published': isPublished,
      'is_offline_available': isOfflineAvailable,
      'view_count': viewCount,
      'download_count': downloadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Resource copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    ResourceCategory? category,
    List<String>? tags,
    String? authorId,
    String? authorName,
    String? imageUrl,
    int? readingTimeMinutes,
    String? language,
    bool? isPublished,
    bool? isOfflineAvailable,
    int? viewCount,
    int? downloadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSaved,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      imageUrl: imageUrl ?? this.imageUrl,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      language: language ?? this.language,
      isPublished: isPublished ?? this.isPublished,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
      viewCount: viewCount ?? this.viewCount,
      downloadCount: downloadCount ?? this.downloadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum ResourceCategory {
  mentalHealth('mental-health', 'Mental Health'),
  srhr('srhr', 'SRHR'),
  emergency('emergency', 'Emergency'),
  substanceUse('substance-use', 'Substance Use'),
  wellness('wellness', 'Wellness'),
  guide('guide', 'Guide');

  final String name;
  final String label;
  const ResourceCategory(this.name, this.label);

  String get id => name;

  static ResourceCategory fromString(String value) {
    return ResourceCategory.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => ResourceCategory.wellness,
    );
  }

  static ResourceCategory fromJson(Object? json) {
    if (json is String) return fromString(json);
    if (json is Map<String, dynamic>) {
      return fromString((json['id'] ?? json['name'] ?? json['label']).toString());
    }
    return ResourceCategory.wellness;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
    };
  }
}

class ResourceListResponse {
  final List<Resource> resources;
  final int total;
  final bool hasMore;

  ResourceListResponse({
    required this.resources,
    required this.total,
    required this.hasMore,
  });

  factory ResourceListResponse.fromJson(Map<String, dynamic> json) {
    return ResourceListResponse(
      resources: (json['resources'] as List<dynamic>?)
          ?.map((e) => Resource.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resources': resources.map((resource) => resource.toJson()).toList(),
      'total': total,
      'hasMore': hasMore,
    };
  }
}

class OfflineResource {
  final String id;
  final String title;
  final String content;
  final ResourceCategory category;
  final List<String> tags;
  final int? readingTimeMinutes;
  final DateTime downloadedAt;

  OfflineResource({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    this.readingTimeMinutes,
    required this.downloadedAt,
  });

  factory OfflineResource.fromJson(Map<String, dynamic> json) {
    return OfflineResource(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: ResourceCategory.fromString(json['category'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      readingTimeMinutes: json['readingTimeMinutes'] as int? ?? json['reading_time_minutes'] as int?,
      downloadedAt: DateTime.parse(
        (json['downloadedAt'] ?? json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.name,
      'tags': tags,
      'readingTimeMinutes': readingTimeMinutes,
      'downloadedAt': downloadedAt.toIso8601String(),
    };
  }

  Resource toResource() {
    return Resource(
      id: id,
      title: title,
      description: content.length > 100 
          ? '${content.substring(0, 100)}...' 
          : content,
      content: content,
      category: category,
      tags: tags,
      readingTimeMinutes: readingTimeMinutes,
      isOfflineAvailable: true,
      createdAt: downloadedAt,
    );
  }
}
