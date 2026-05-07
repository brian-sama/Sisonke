import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/models/recovery_tracker.dart';
import 'package:sisonke/core/services/local_database_service.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:uuid/uuid.dart';

final recoveryEntriesProvider = StateNotifierProvider<RecoveryNotifier, List<RecoveryEntry>>((ref) {
  final dbService = ref.watch(localDatabaseServiceProvider);
  return RecoveryNotifier(dbService);
});

class RecoveryNotifier extends StateNotifier<List<RecoveryEntry>> {
  final LocalDatabaseService _dbService;

  RecoveryNotifier(this._dbService) : super([]) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    final entries = await _dbService.getAllRecoveryEntries();
    state = entries;
  }

  Future<void> addEntry({
    required RecoveryEventType type,
    String? reflection,
  }) async {
    int streak = 0;
    if (type == RecoveryEventType.victory) {
      if (state.isNotEmpty) {
        final last = state.first;
        if (last.type == RecoveryEventType.victory) {
          final now = DateTime.now();
          final lastDate = DateTime(last.timestamp.year, last.timestamp.month, last.timestamp.day);
          final todayDate = DateTime(now.year, now.month, now.day);
          final diff = todayDate.difference(lastDate).inDays;
          
          if (diff == 0) {
            // Already logged a victory today, preserve current streak
            streak = last.streakDays ?? 1;
          } else if (diff == 1) {
            // Yesterday was a victory, increment streak
            streak = (last.streakDays ?? 0) + 1;
          } else {
            // Gapped day, reset streak to 1
            streak = 1;
          }
        } else {
          // Last entry was a relapse/reset, start new streak
          streak = 1;
        }
      } else {
        // First entry ever
        streak = 1;
      }
    } else {
      // Relapse resets streak to 0
      streak = 0;
    }

    final entry = RecoveryEntry(
      id: const Uuid().v4(),
      type: type,
      timestamp: DateTime.now(),
      reflection: reflection,
      streakDays: streak,
    );
    
    await _dbService.saveRecoveryEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(int isarId) async {
    await _dbService.deleteRecoveryEntry(isarId);
    await loadEntries();
  }
}
