import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/features/mood_tracker/providers/mood_provider.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/features/checkin/screens/mood_checkin_screen.dart';
import 'package:sisonke/app/core/services/providers.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen> {
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
    final moods = ref.watch(moodEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: moods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mood, size: 64, color: Colors.grey),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const Text('No mood check-ins yet', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: AppConstants.spacingLarge),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MoodCheckinScreen()),
                    ),
                    child: const Text('Check-in Now'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              itemCount: moods.length,
              itemBuilder: (context, index) {
                final entry = moods[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
                  child: ListTile(
                    leading: Text(entry.mood.emoji, style: const TextStyle(fontSize: 32)),
                    title: Text(entry.mood.label),
                    subtitle: Text(
                      '${DateFormat('MMM dd, hh:mm a').format(entry.timestamp)} • Energy: ${entry.energyLevel}',
                    ),
                    trailing: entry.note != null ? const Icon(Icons.note_alt_outlined) : null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoodCheckinScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
