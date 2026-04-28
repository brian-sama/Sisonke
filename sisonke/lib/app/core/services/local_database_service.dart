import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/shared/models/journal.dart';
import 'package:sisonke/shared/models/recovery_tracker.dart';

class LocalDatabaseService {
  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [MoodEntrySchema, JournalEntrySchema, RecoveryEntrySchema],
      directory: dir.path,
    );
  }

  Isar get isar => _isar;

  // Mood Methods
  Future<void> saveMood(MoodEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.moodEntrys.put(entry);
    });
  }

  Future<List<MoodEntry>> getAllMoods() async {
    return await _isar.moodEntrys.where().sortByTimestampDesc().findAll();
  }

  Future<void> deleteMood(int id) async {
    await _isar.writeTxn(() async {
      await _isar.moodEntrys.delete(id);
    });
  }

  // Journal Methods
  Future<void> saveJournal(JournalEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.journalEntrys.put(entry);
    });
  }

  Future<List<JournalEntry>> getAllJournals() async {
    return await _isar.journalEntrys.where().sortByCreatedAtDesc().findAll();
  }

  Future<JournalEntry?> getJournalById(int id) async {
    return await _isar.journalEntrys.get(id);
  }

  Future<void> deleteJournal(int id) async {
    await _isar.writeTxn(() async {
      await _isar.journalEntrys.delete(id);
    });
  }

  // Recovery Methods
  Future<void> saveRecoveryEntry(RecoveryEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.recoveryEntrys.put(entry);
    });
  }

  Future<List<RecoveryEntry>> getAllRecoveryEntries() async {
    return await _isar.recoveryEntrys.where().sortByTimestampDesc().findAll();
  }

  Future<void> deleteRecoveryEntry(int id) async {
    await _isar.writeTxn(() async {
      await _isar.recoveryEntrys.delete(id);
    });
  }
}
