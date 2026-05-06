import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/core/services/local_database_service.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:sisonke/core/services/widget_service.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:uuid/uuid.dart';

final moodEntriesProvider =
    StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
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

    try {
      final journals = await _dbService.getAllJournals();
      final gratitudeCount = journals
          .where((j) => j.tags.contains('gratitude'))
          .length;

      await WidgetService.syncSnapshot(
        WidgetService.snapshotForMood(
          mood: mood,
          gratitudeStars: gratitudeCount,
        ),
      );
    } catch (_) {
      // Widget sync should never block mood logging.
    }
  }

  Future<void> deleteMood(int isarId) async {
    await _dbService.deleteMood(isarId);
    await loadMoods();
  }
}
