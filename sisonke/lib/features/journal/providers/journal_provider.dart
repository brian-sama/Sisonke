import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/models/journal.dart';
import 'package:sisonke/app/core/services/local_database_service.dart';
import 'package:sisonke/app/core/services/providers.dart';
import 'package:sisonke/features/journal/services/journal_encryption_service.dart';
import 'package:sisonke/features/mood_tracker/providers/mood_provider.dart';
import 'package:uuid/uuid.dart';

final journalEncryptionServiceProvider = Provider<JournalEncryptionService>((ref) {
  return JournalEncryptionService();
});

final journalEntriesProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  final dbService = ref.watch(localDatabaseServiceProvider);
  final encryptionService = ref.watch(journalEncryptionServiceProvider);
  return JournalNotifier(dbService, encryptionService);
});

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  final LocalDatabaseService _dbService;
  final JournalEncryptionService _encryptionService;

  JournalNotifier(this._dbService, this._encryptionService) : super([]) {
    loadJournals();
  }

  Future<void> loadJournals() async {
    final journals = await _dbService.getAllJournals();
    state = journals;
  }

  Future<void> addEntry({
    required String title,
    required String content,
    String? moodAtTime,
    List<String> tags = const [],
    bool isLocked = false,
  }) async {
    final encryptedContent = await _encryptionService.encrypt(content);
    
    final entry = JournalEntry(
      id: const Uuid().v4(),
      title: title,
      content: encryptedContent,
      createdAt: DateTime.now(),
      moodAtTime: moodAtTime,
      tags: tags,
      isLocked: isLocked,
    );
    
    await _dbService.saveJournal(entry);
    await loadJournals();
  }

  Future<String> getDecryptedContent(String encryptedContent) async {
    return await _encryptionService.decrypt(encryptedContent);
  }

  Future<void> deleteEntry(int isarId) async {
    await _dbService.deleteJournal(isarId);
    await loadJournals();
  }
}
