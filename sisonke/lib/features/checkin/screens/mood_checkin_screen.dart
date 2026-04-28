import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/features/mood_tracker/providers/mood_provider.dart';
import 'package:sisonke/core/constants/app_constants.dart';

class MoodCheckinScreen extends ConsumerStatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  ConsumerState<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends ConsumerState<MoodCheckinScreen> {
  MoodType? _selectedMood;
  double _energyLevel = 5.0;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveCheckin() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select how you are feeling')),
      );
      return;
    }

    await ref.read(moodEntriesProvider.notifier).addMood(
      mood: _selectedMood!,
      energyLevel: _energyLevel.toInt(),
      note: _noteController.text,
    );

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood check-in saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your current mood:',
              style: TextStyle(fontSize: AppConstants.textLarge, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: MoodType.values.length,
              itemBuilder: (context, index) {
                final mood = MoodType.values[index];
                final isSelected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey[200],
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                        Text(mood.label, style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingXLarge),
            Text(
              'Energy Level: ${_energyLevel.toInt()}',
              style: const TextStyle(fontSize: AppConstants.textMedium, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _energyLevel,
              min: 1,
              max: 10,
              divisions: 9,
              label: _energyLevel.toInt().toString(),
              onChanged: (value) => setState(() => _energyLevel = value),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Add a note (optional)',
                border: OutlineInputBorder(),
                hintText: 'What\'s on your mind?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.spacingXLarge),
            ElevatedButton(
              onPressed: _saveCheckin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMedium),
              ),
              child: const Text('Save Check-in'),
            ),
          ],
        ),
      ),
    );
  }
}
