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
    // Simple streak calculation (placeholder)
    int streak = 0;
    if (type == RecoveryEventType.victory) {
      if (state.isNotEmpty && state.first.type == RecoveryEventType.victory) {
        streak = (state.first.streakDays ?? 0) + 1;
      } else {
        streak = 1;
      }
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
