import 'package:sisonke/shared/models/mood.dart';

class TriggerStat {
  final String tag;
  final int totalCount;
  final int difficultCount;
  final double difficultRatio;
  final String insightMessage;
  final String suggestion;

  const TriggerStat({
    required this.tag,
    required this.totalCount,
    required this.difficultCount,
    required this.difficultRatio,
    required this.insightMessage,
    required this.suggestion,
  });
}

class PatternAnalysis {
  final List<TriggerStat> topTriggers;
  final String timeOfDayInsight;
  final String timeOfDaySuggestion;
  final String dayOfWeekInsight;
  final String dayOfWeekSuggestion;
  final String energyInsight;
  final String overallSummary;
  final bool hasSufficientData;

  const PatternAnalysis({
    required this.topTriggers,
    required this.timeOfDayInsight,
    required this.timeOfDaySuggestion,
    required this.dayOfWeekInsight,
    required this.dayOfWeekSuggestion,
    required this.energyInsight,
    required this.overallSummary,
    required this.hasSufficientData,
  });
}

class TriggerPatternService {
  static const List<String> standardTriggers = [
    '😴 Sleep Deprivation',
    '🎓 Study & Deadlines',
    '💼 Work Pressure',
    '👥 Relationships',
    '🌧️ Loneliness',
    '🏠 Family Friction',
    '💰 Finances',
    '📱 Social Media Overload',
    '⚡ Sensory Overstimulation',
    '🏃 Physical Exhaustion',
  ];

  static bool _isDifficult(MoodType mood) {
    return mood == MoodType.low ||
        mood == MoodType.anxious ||
        mood == MoodType.angry ||
        mood == MoodType.overwhelmed;
  }

  static PatternAnalysis analyze(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return const PatternAnalysis(
        topTriggers: [
          TriggerStat(
            tag: '😴 Sleep Deprivation',
            totalCount: 0,
            difficultCount: 0,
            difficultRatio: 0.0,
            insightMessage: 'Disrupted sleep frequently lowers emotional resilience.',
            suggestion: 'Wind down with a 5-minute calm breathing session before sleep.',
          ),
          TriggerStat(
            tag: '🎓 Study & Work',
            totalCount: 0,
            difficultCount: 0,
            difficultRatio: 0.0,
            insightMessage: 'High-stake deadlines can silently increase cognitive fog.',
            suggestion: 'Break tasks into 20-minute chunks and talk with Feelix or Felicia.',
          ),
        ],
        timeOfDayInsight: 'Late evenings (10 PM - 3 AM) are commonly when ruminating thoughts peak.',
        timeOfDaySuggestion: 'Try a grounding exercise or journal before bed.',
        dayOfWeekInsight: 'Midweek dips often emerge around Wednesday afternoons.',
        dayOfWeekSuggestion: 'Plan micro-breaks to preserve emotional reserves.',
        energyInsight: 'Energy levels below 4/10 correlate with heightened emotional vulnerability.',
        overallSummary: 'Log your reflections to help Serevo uncover your personal emotional rhythms.',
        hasSufficientData: false,
      );
    }

    // 1. Analyze Trigger Tags
    final tagTotal = <String, int>{};
    final tagDifficult = <String, int>{};

    for (final e in entries) {
      final isDiff = _isDifficult(e.mood);
      for (final tag in e.tags) {
        tagTotal[tag] = (tagTotal[tag] ?? 0) + 1;
        if (isDiff) {
          tagDifficult[tag] = (tagDifficult[tag] ?? 0) + 1;
        }
      }
    }

    final triggerStats = <TriggerStat>[];
    for (final entry in tagTotal.entries) {
      final tag = entry.key;
      final total = entry.value;
      final diff = tagDifficult[tag] ?? 0;
      final ratio = total > 0 ? (diff / total) : 0.0;

      String suggestion;
      if (tag.toLowerCase().contains('sleep')) {
        suggestion = 'Set a restful bedtime routine; listen to soothing audio or breathe with Serevo.';
      } else if (tag.toLowerCase().contains('study') || tag.toLowerCase().contains('work')) {
        suggestion = 'Try box breathing and schedule short 5-minute pauses between study blocks.';
      } else if (tag.toLowerCase().contains('lonel') || tag.toLowerCase().contains('isolat')) {
        suggestion = 'Step into an Ubuntu Circle or message Felicia/Feelix for companionship.';
      } else if (tag.toLowerCase().contains('fam') || tag.toLowerCase().contains('relat')) {
        suggestion = 'Ground your feelings before reacting; remember your boundaries are valid.';
      } else {
        suggestion = 'Reflect gently in your private journal and release self-judgment.';
      }

      triggerStats.add(TriggerStat(
        tag: tag,
        totalCount: total,
        difficultCount: diff,
        difficultRatio: ratio,
        insightMessage: diff > 0
            ? 'Present in $diff out of $total challenging moments (${(ratio * 100).toInt()}% impact)'
            : 'Associated with steady and calm reflections ($total logged)',
        suggestion: suggestion,
      ));
    }

    // Sort triggers by difficult count, then ratio
    triggerStats.sort((a, b) {
      final diffComp = b.difficultCount.compareTo(a.difficultCount);
      if (diffComp != 0) return diffComp;
      return b.difficultRatio.compareTo(a.difficultRatio);
    });

    // 2. Time of Day Pattern
    // Morning (5-11), Afternoon (12-16), Evening (17-21), Night (22-4)
    final timeSlots = {'Morning': 0, 'Afternoon': 0, 'Evening': 0, 'Night': 0};
    final diffTimeSlots = {'Morning': 0, 'Afternoon': 0, 'Evening': 0, 'Night': 0};

    for (final e in entries) {
      final hour = e.timestamp.hour;
      String slot;
      if (hour >= 5 && hour < 12) {
        slot = 'Morning';
      } else if (hour >= 12 && hour < 17) {
        slot = 'Afternoon';
      } else if (hour >= 17 && hour < 22) {
        slot = 'Evening';
      } else {
        slot = 'Night';
      }

      timeSlots[slot] = (timeSlots[slot] ?? 0) + 1;
      if (_isDifficult(e.mood)) {
        diffTimeSlots[slot] = (diffTimeSlots[slot] ?? 0) + 1;
      }
    }

    String topDiffSlot = 'Night';
    int maxDiffSlotCount = -1;
    for (final entry in diffTimeSlots.entries) {
      if (entry.value > maxDiffSlotCount) {
        maxDiffSlotCount = entry.value;
        topDiffSlot = entry.key;
      }
    }

    String timeOfDayInsight;
    String timeOfDaySuggestion;
    if (maxDiffSlotCount > 0) {
      timeOfDayInsight = '$topDiffSlot Vulnerability: $maxDiffSlotCount of your challenging moods occurred during $topDiffSlot hours.';
      timeOfDaySuggestion = topDiffSlot == 'Night'
          ? 'Late hours can magnify worries. Try switching off screens earlier or journaling before sleep.'
          : 'Schedule a comforting reset midway through your $topDiffSlot.';
    } else {
      timeOfDayInsight = 'Even distribution: Your emotional flow is relatively balanced across the day.';
      timeOfDaySuggestion = 'Continue checking in morning and evening to maintain self-awareness.';
    }

    // 3. Day of Week Pattern
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayEnergy = <int, List<int>>{};
    final dayDiffCount = <int, int>{};

    for (final e in entries) {
      final wd = e.timestamp.weekday;
      dayEnergy.putIfAbsent(wd, () => []).add(e.energyLevel);
      if (_isDifficult(e.mood)) {
        dayDiffCount[wd] = (dayDiffCount[wd] ?? 0) + 1;
      }
    }

    int lowestEnergyDay = 3; // default Wed
    double minAvgEnergy = 100.0;
    for (final entry in dayEnergy.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg < minAvgEnergy) {
        minAvgEnergy = avg;
        lowestEnergyDay = entry.key;
      }
    }

    String dayOfWeekInsight;
    String dayOfWeekSuggestion;
    if (dayEnergy.isNotEmpty) {
      dayOfWeekInsight = '${days[lowestEnergyDay]} Energy Dip: Energy averages ${minAvgEnergy.toStringAsFixed(1)}/10 on ${days[lowestEnergyDay]}s.';
      dayOfWeekSuggestion = 'Treat ${days[lowestEnergyDay]}s with extra compassion and lighter expectations.';
    } else {
      dayOfWeekInsight = 'Weekly rhythm developing.';
      dayOfWeekSuggestion = 'Check in across weekdays to map your energy cycles.';
    }

    // 4. Energy vs Stress correlation
    final lowEnergyDiffEntries = entries.where((e) => e.energyLevel <= 4 && _isDifficult(e.mood)).length;
    final totalLowEnergy = entries.where((e) => e.energyLevel <= 4).length;
    String energyInsight;
    if (totalLowEnergy > 0) {
      final pct = ((lowEnergyDiffEntries / totalLowEnergy) * 100).toInt();
      energyInsight = 'When your energy dips below 4, $pct% of reflections are heavy or overwhelmed.';
    } else {
      energyInsight = 'Higher energy levels consistently support a calm or hopeful state of mind.';
    }

    final topTriggerName = triggerStats.isNotEmpty ? triggerStats.first.tag : 'daily routines';
    final overallSummary = 'Primary emotional trigger detected around "$topTriggerName", especially noticeable during $topDiffSlot hours.';

    return PatternAnalysis(
      topTriggers: triggerStats,
      timeOfDayInsight: timeOfDayInsight,
      timeOfDaySuggestion: timeOfDaySuggestion,
      dayOfWeekInsight: dayOfWeekInsight,
      dayOfWeekSuggestion: dayOfWeekSuggestion,
      energyInsight: energyInsight,
      overallSummary: overallSummary,
      hasSufficientData: entries.length >= 2,
    );
  }
}
