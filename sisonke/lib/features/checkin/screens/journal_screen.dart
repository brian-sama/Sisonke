import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sisonke/features/journal/providers/journal_provider.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/features/checkin/screens/journal_entry_screen.dart';
import 'package:sisonke/app/core/services/providers.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  @override
  void initState() {
    super.initState();
    _enableProtection();
  }

  @override
  void dispose() {
    _disableProtection();
    super.dispose();
  }

  void _enableProtection() async {
    await ref.read(securityServiceProvider).enableScreenshotProtection();
  }

  void _disableProtection() async {
    await ref.read(securityServiceProvider).disableScreenshotProtection();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalEntriesProvider);
    final securityService = ref.read(securityServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note, size: 64, color: Colors.grey),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const Text('No journal entries yet', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: AppConstants.spacingLarge),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JournalEntryScreen()),
                    ),
                    child: const Text('Start Writing'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
                  child: ListTile(
                    title: Text(entry.title.isEmpty ? 'Untitled' : entry.title),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(entry.createdAt),
                    ),
                    trailing: entry.isLocked ? const Icon(Icons.lock_outline) : null,
                    onTap: () async {
                      if (entry.isLocked) {
                        final authenticated = await securityService.authenticate();
                        if (!authenticated) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Authentication failed')),
                            );
                          }
                          return;
                        }
                      }
                      
                      final decryptedContent = await ref.read(journalEntriesProvider.notifier).getDecryptedContent(entry.content);
                      
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(entry.title.isEmpty ? 'Untitled' : entry.title),
                            content: SingleChildScrollView(child: Text(decryptedContent)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(journalEntriesProvider.notifier).deleteEntry(entry.isarId!);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JournalEntryScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
