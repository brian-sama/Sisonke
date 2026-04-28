import 'package:isar/isar.dart';

part 'journal.g.dart';

/// Represents a journal entry
@collection
class JournalEntry {
  Id? isarId;

  final String id;
  final String title;
  final String content; // Will be encrypted
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? moodAtTime;
  final List<String> tags;
  final bool isLocked;

  JournalEntry({
    this.isarId,
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.moodAtTime,
    this.tags = const [],
    this.isLocked = false,
  });

  JournalEntry copyWith({
    Id? isarId,
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? moodAtTime,
    List<String>? tags,
    bool? isLocked,
  }) {
    return JournalEntry(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moodAtTime: moodAtTime ?? this.moodAtTime,
      tags: tags ?? this.tags,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
