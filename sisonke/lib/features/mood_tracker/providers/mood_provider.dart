import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/app/core/services/local_database_service.dart';
import 'package:sisonke/app/core/services/providers.dart';
import 'package:uuid/uuid.dart';

final moodEntriesProvider = StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  final dbService = ref.watch(localDatabaseServiceProvider);
  return MoodNotifier(dbService);
});

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  final LocalDatabaseService _dbService;

  MoodNotifier(this._dbService) : super([]) {
    loadMoods();
  }

  Future<void> loadMoods() async {
    final moods = await _dbService.getAllMoods();
    state = moods;
  }

  Future<void> addMood({
    required MoodType mood,
    int energyLevel = 5,
    String? note,
    List<String> tags = const [],
  }) async {
    final entry = MoodEntry(
      id: const Uuid().v4(),
      mood: mood,
      timestamp: DateTime.now(),
      energyLevel: energyLevel,
      note: note,
      tags: tags,
    );
    
    await _dbService.saveMood(entry);
    await loadMoods();
  }

  Future<void> deleteMood(int isarId) async {
    await _dbService.deleteMood(isarId);
    await loadMoods();
  }
}
