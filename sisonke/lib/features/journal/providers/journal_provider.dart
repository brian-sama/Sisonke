import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sisonke/shared/models/journal.dart';
import 'package:sisonke/core/services/local_database_service.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:sisonke/features/journal/services/journal_encryption_service.dart';
import 'package:uuid/uuid.dart';

const _ownerTagPrefix = 'owner:';
const _anonymousOwnerId = 'anonymous_local';

final journalEncryptionServiceProvider = Provider<JournalEncryptionService>((
  ref,
) {
  return JournalEncryptionService();
});

final journalEntriesProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
      final dbService = ref.watch(localDatabaseServiceProvider);
      final encryptionService = ref.watch(journalEncryptionServiceProvider);
      return JournalNotifier(dbService, encryptionService);
    });

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  final LocalDatabaseService _dbService;
  final JournalEncryptionService _encryptionService;
  final FlutterSecureStorage _secureStorage;

  JournalNotifier(
    this._dbService,
    this._encryptionService, {
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       super([]) {
    loadJournals();
  }

  Future<String> _resolveOwnerId() async {
    final stored =
        await _secureStorage.read(key: 'user_id') ??
        await _secureStorage.read(key: 'auth_user_id');
    return (stored != null && stored.isNotEmpty) ? stored : _anonymousOwnerId;
  }

  Future<void> loadJournals() async {
    final ownerId = await _resolveOwnerId();
    final activeOwnerTag = await _encryptionService.ownerTag(ownerId);
    final rawJournals = await _dbService.getAllJournals();

    final visible = <JournalEntry>[];
    for (final entry in rawJournals) {
      final entryOwnerTags = entry.tags
          .where((t) => t.startsWith(_ownerTagPrefix))
          .toList();
      final isOwned = entryOwnerTags.isEmpty
          ? ownerId == _anonymousOwnerId
          : entryOwnerTags.contains(activeOwnerTag);
      if (!isOwned) continue;

      final decryptedTitle = await _encryptionService.decryptField(entry.title);
      final decryptedMood = entry.moodAtTime != null
          ? await _encryptionService.decryptField(entry.moodAtTime!)
          : null;
      final decryptedTags = <String>[];
      for (final tag in entry.tags) {
        if (tag.startsWith(_ownerTagPrefix)) continue;
        decryptedTags.add(await _encryptionService.decryptField(tag));
      }

      visible.add(
        entry.copyWith(
          title: decryptedTitle,
          moodAtTime: decryptedMood,
          tags: decryptedTags,
        ),
      );
    }
    state = visible;
  }

  Future<void> addEntry({
    required String title,
    required String content,
    String? moodAtTime,
    List<String> tags = const [],
    bool isLocked = false,
  }) async {
    final ownerId = await _resolveOwnerId();
    final activeOwnerTag = await _encryptionService.ownerTag(ownerId);

    // Encrypt body AND sensitive metadata (title, mood, tags) at rest (audit §3.1 A).
    final encryptedTitle = await _encryptionService.encryptField(title);
    final encryptedContent = await _encryptionService.encrypt(content);
    final encryptedMood = moodAtTime != null
        ? await _encryptionService.encryptField(moodAtTime)
        : null;
    final encryptedTags = <String>[activeOwnerTag];
    for (final tag in tags) {
      if (tag.startsWith(_ownerTagPrefix)) continue;
      encryptedTags.add(await _encryptionService.encryptField(tag));
    }

    final entry = JournalEntry(
      id: const Uuid().v4(),
      title: encryptedTitle,
      content: encryptedContent,
      createdAt: DateTime.now(),
      moodAtTime: encryptedMood,
      tags: encryptedTags,
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
