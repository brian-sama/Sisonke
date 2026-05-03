import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/models/index.dart';

/// Provider for journal entries
final journalEntriesProvider = StateProvider<List<JournalEntry>>((ref) => []);

/// Provider for journal search query
final journalSearchProvider = StateProvider<String>((ref) => '');

/// Provider for filtered journal entries
final filteredJournalEntriesProvider =
    StateProvider<List<JournalEntry>>((ref) {
  final entries = ref.watch(journalEntriesProvider);
  final searchQuery = ref.watch(journalSearchProvider);

  if (searchQuery.isEmpty) {
    return entries;
  }

  return entries
      .where((e) =>
          e.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          e.content.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();
});

/// Provider for journal detail
final journalDetailProvider =
    StateProvider.family<JournalEntry?, String>((ref, entryId) {
  final entries = ref.watch(journalEntriesProvider);
  try {
    return entries.firstWhere((e) => e.id == entryId);
  } catch (e) {
    return null;
  }
});

/// Provider for journal lock status
final journalLockedProvider = StateProvider<bool>((ref) => false);

