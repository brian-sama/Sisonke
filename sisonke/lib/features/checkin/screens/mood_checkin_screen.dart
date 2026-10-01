import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/features/checkin/providers/mood_provider.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

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

  Gradient _ambientGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      switch (_selectedMood) {
        case MoodType.great:
        case MoodType.okay:
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10131C), Color(0xFF162320)],
          );
        case MoodType.low:
        case MoodType.overwhelmed:
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10131C), Color(0xFF17202B)],
          );
        case MoodType.anxious:
        case MoodType.angry:
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10131C), Color(0xFF261820)],
          );
        case null:
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10131C), Color(0xFF171B26)],
          );
      }
    }

    switch (_selectedMood) {
      case MoodType.great:
        return SisonkeColors.forestBreeze;
      case MoodType.okay:
        return SisonkeColors.forestBreeze;
      case MoodType.low:
      case MoodType.overwhelmed:
        return SisonkeColors.morningMist;
      case MoodType.anxious:
      case MoodType.angry:
        return SisonkeColors.pastelSunset;
      case null:
        return SisonkeColors.forestBreeze;
    }
  }

  void _saveCheckin() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFD68A7F),
          content: Text(
            'Please select an organic state representing your mood.',
          ),
        ),
      );
      return;
    }

    await ref
        .read(moodEntriesProvider.notifier)
        .addMood(
          mood: _selectedMood!,
          energyLevel: _energyLevel.toInt(),
          note: _noteController.text,
        );

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E6F60),
          content: Text(
            'Your organic mood reflection is saved safely inside Sisonke.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white.withValues(alpha: 0.7);
    final cardBorder = isDark ? theme.colorScheme.outlineVariant : Colors.white.withValues(alpha: 0.4);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Daily Reflection'),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(gradient: _ambientGradient(context)),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How is your inner season today?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select the nature token that closest resembles your emotional environment:',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  ? (isDark
                                      ? theme.colorScheme.primary.withValues(alpha: 0.25)
                                      : const Color(0xFF2E6F60).withValues(alpha: 0.18))
                                  : (isDark
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : Colors.white.withValues(alpha: 0.6)),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60))
                                    : (isDark ? theme.colorScheme.outlineVariant : Colors.white.withValues(alpha: 0.5)),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60)).withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mood.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood.localLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mood.localNote,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor,
                                    fontStyle: FontStyle.italic,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Energy Reservoir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        Text(
                          '${_energyLevel.toInt()} / 10',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60),
                        inactiveTrackColor: (isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60)).withValues(alpha: 0.15),
                        thumbColor: isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60),
                        overlayColor: (isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60)).withValues(alpha: 0.12),
                        valueIndicatorColor: isDark ? theme.colorScheme.primary : const Color(0xFF2E6F60),
                      ),
                      child: Slider(
                        value: _energyLevel,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _energyLevel.toInt().toString(),
                        onChanged: (value) =>
                            setState(() => _energyLevel = value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'What made today feel this way?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryTextColor,
                      ),
                      decoration: InputDecoration(
                        fillColor: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : Colors.white.withValues(alpha: 0.85),
                        hintText:
                            'Take your time, write as little or as much as you need...',
                        hintStyle: TextStyle(
                          color: secondaryTextColor,
                        ),
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
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
