import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/models/index.dart';

/// Provider for mood entries
final moodEntriesProvider = StateProvider<List<MoodEntry>>((ref) => []);

/// Provider for latest mood
final latestMoodProvider = StateProvider<MoodEntry?>((ref) {
  final moods = ref.watch(moodEntriesProvider);
  if (moods.isEmpty) return null;
  return moods.last;
});

/// Provider for mood history (filtered by date range)
final moodHistoryProvider =
    StateProvider<List<MoodEntry>>((ref) {
  final moods = ref.watch(moodEntriesProvider);
  return moods;
});

/// Provider for mood trends
final moodTrendsProvider = StateProvider<MoodTrends>((ref) {
  final moods = ref.watch(moodEntriesProvider);
  return MoodTrends.fromEntries(moods);
});

class MoodTrends {
  final int totalEntries;
  final MoodType mostCommonMood;
  final double averageEnergyLevel;
  final Map<MoodType, int> moodCounts;

  MoodTrends({
    required this.totalEntries,
    required this.mostCommonMood,
    required this.averageEnergyLevel,
    required this.moodCounts,
  });

  factory MoodTrends.fromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return MoodTrends(
        totalEntries: 0,
        mostCommonMood: MoodType.okay,
        averageEnergyLevel: 5,
        moodCounts: {},
      );
    }

    final moodCounts = <MoodType, int>{};
    var totalEnergy = 0;

    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      totalEnergy += entry.energyLevel;
    }

    final mostCommon = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return MoodTrends(
      totalEntries: entries.length,
      mostCommonMood: mostCommon,
      averageEnergyLevel: totalEnergy / entries.length,
      moodCounts: moodCounts,
    );
  }
}

