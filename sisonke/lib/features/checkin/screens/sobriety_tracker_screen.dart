import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sisonke/shared/models/recovery_tracker.dart';
import 'package:sisonke/features/checkin/providers/recovery_provider.dart';
import 'package:sisonke/core/constants/app_constants.dart';

class SobrietyTrackerScreen extends ConsumerWidget {
  const SobrietyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(recoveryEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Tracker'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStreakCard(entries),
          const Divider(),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No recovery entries yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        child: ListTile(
                          leading: Text(entry.type.emoji, style: const TextStyle(fontSize: 24)),
                          title: Text(entry.type.label),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy - hh:mm a').format(entry.timestamp),
                          ),
                          trailing: entry.streakDays != null && entry.streakDays! > 0
                              ? Chip(label: Text('${entry.streakDays} day streak'))
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(context, ref),
        label: const Text('Add Log'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStreakCard(List<RecoveryEntry> entries) {
    int currentStreak = 0;
    if (entries.isNotEmpty && entries.first.type == RecoveryEventType.victory) {
      currentStreak = entries.first.streakDays ?? 0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
      ),
      child: Column(
        children: [
          const Text('Current Victory Streak', style: TextStyle(fontSize: 16)),
          Text(
            '$currentStreak Days',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const Text('Keep going! You are doing great.', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Log Recovery Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spacingMedium),
            ListTile(
              leading: Text(RecoveryEventType.victory.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(RecoveryEventType.victory.label),
              onTap: () {
                ref.read(recoveryEntriesProvider.notifier).addEntry(type: RecoveryEventType.victory);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text(RecoveryEventType.urge.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(RecoveryEventType.urge.label),
              onTap: () {
                ref.read(recoveryEntriesProvider.notifier).addEntry(type: RecoveryEventType.urge);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text(RecoveryEventType.relapse.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(RecoveryEventType.relapse.label),
              onTap: () {
                ref.read(recoveryEntriesProvider.notifier).addEntry(type: RecoveryEventType.relapse);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
