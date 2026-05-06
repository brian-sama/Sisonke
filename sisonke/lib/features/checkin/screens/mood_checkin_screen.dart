import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/features/mood_tracker/providers/mood_provider.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

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

  Gradient get _ambientGradient {
    switch (_selectedMood) {
      case MoodType.great:
        return SisonkeColors.forestBreeze; // warm sunlight / sage
      case MoodType.okay:
        return SisonkeColors.forestBreeze;
      case MoodType.low:
      case MoodType.overwhelmed:
        return SisonkeColors.morningMist; // cool sky blues / mint
      case MoodType.anxious:
      case MoodType.angry:
        return SisonkeColors.pastelSunset; // sunset rose / lavender
      case null:
        return SisonkeColors.forestBreeze;
    }
  }

  void _saveCheckin() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFD68A7F),
          content: Text('Please select an organic state representing your mood.'),
        ),
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
        const SnackBar(
          backgroundColor: Color(0xFF2E6F60),
          content: Text('Your organic mood reflection is saved safely inside Sisonke.', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(
        title: 'Daily Reflection',
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: _ambientGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How is your inner season today?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2F3433),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select the nature token that closest resembles your emotional environment:',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF2F3433).withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: MoodType.values.length,
                      itemBuilder: (context, index) {
                        final mood = MoodType.values[index];
                        final isSelected = _selectedMood == mood;
                        return InkWell(
                          onTap: () => setState(() => _selectedMood = mood),
                          borderRadius: BorderRadius.circular(24),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E6F60).withOpacity(0.18)
                                  : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E6F60)
                                    : Colors.white.withOpacity(0.5),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF2E6F60).withOpacity(0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(mood.emoji, style: const TextStyle(fontSize: 34)),
                                const SizedBox(height: 4),
                                Text(
                                  mood.label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                    color: const Color(0xFF2F3433),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Energy Presence',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3433),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E6F60).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_energyLevel.toInt()} / 10',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E6F60),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF2E6F60),
                        inactiveTrackColor: const Color(0xFF2E6F60).withOpacity(0.15),
                        thumbColor: const Color(0xFF2E6F60),
                        overlayColor: const Color(0xFF2E6F60).withOpacity(0.12),
                        valueIndicatorColor: const Color(0xFF2E6F60),
                      ),
                      child: Slider(
                        value: _energyLevel,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _energyLevel.toInt().toString(),
                        onChanged: (value) => setState(() => _energyLevel = value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'What made today feel this way?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F3433),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        fillColor: Colors.white.withOpacity(0.85),
                        hintText: 'Take your time, write as little or as much as you need...',
                        hintStyle: TextStyle(color: const Color(0xFF2F3433).withOpacity(0.4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SisonkeButton(
                onPressed: _saveCheckin,
                label: 'Save My Reflection',
                icon: Icons.check_circle_outline_rounded,
                isFullWidth: true,
              ),
              const SizedBox(height: 48), // Bottom safe space
            ],
          ),
        ),
      ),
    );
  }
}
