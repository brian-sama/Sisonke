import 'package:isar/isar.dart';

part 'recovery_tracker.g.dart';

/// Represents a sobriety/recovery tracker entry
@collection
class RecoveryEntry {
  Id? isarId;

  final String id;
  
  @enumerated
  final RecoveryEventType type;
  
  final DateTime timestamp;
  final String? reflection;
  final int? streakDays;

  RecoveryEntry({
    this.isarId,
    required this.id,
    required this.type,
    required this.timestamp,
    this.reflection,
    this.streakDays,
  });

  RecoveryEntry copyWith({
    Id? isarId,
    String? id,
    RecoveryEventType? type,
    DateTime? timestamp,
    String? reflection,
    int? streakDays,
  }) {
    return RecoveryEntry(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      reflection: reflection ?? this.reflection,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

enum RecoveryEventType {
  victory('Victory', '🏆'),
  urge('Urge', '⚠️'),
  relapse('Relapse', '💔');

  final String label;
  final String emoji;
  const RecoveryEventType(this.label, this.emoji);
}
