import 'package:isar/isar.dart';

part 'mood.g.dart';

/// Represents a mood check-in entry
@collection
class MoodEntry {
  Id? isarId;
  
  final String id;
  
  @enumerated
  final MoodType mood;
  
  final DateTime timestamp;
  final String? note;
  final List<String> tags;
  final int energyLevel; // 1-10

  MoodEntry({
    this.isarId,
    required this.id,
    required this.mood,
    required this.timestamp,
    this.note,
    this.tags = const [],
    this.energyLevel = 5,
  });

  MoodEntry copyWith({
    Id? isarId,
    String? id,
    MoodType? mood,
    DateTime? timestamp,
    String? note,
    List<String>? tags,
    int? energyLevel,
  }) {
    return MoodEntry(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      mood: mood ?? this.mood,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      energyLevel: energyLevel ?? this.energyLevel,
    );
  }
}

enum MoodType {
  great(    'Sunlight',      '🌻', 'Kulungile',      'all is well'),          // Ndebele
  okay(     'Gentle Breeze', '🍃', 'Getting by',     'I am managing'),        // English
  low(      'Cool Rain',     '🌧️', 'Ndinosuwa',     'heavy-hearted'),        // Shona
  anxious(  'Storm Cloud',   '⛈️', 'Ngesaba',        'I am afraid'),         // Ndebele
  angry(    'Wild Fire',     '🔥', 'Kutsamwa',       'burning inside'),       // Shona
  overwhelmed('Heavy Fog',   '🌫️', 'Kufungisisa',   'thinking too much');    // Shona

  final String label;
  final String emoji;
  final String localLabel;
  final String localNote;
  const MoodType(this.label, this.emoji, this.localLabel, this.localNote);
}
