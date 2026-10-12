import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/features/checkin/providers/mood_provider.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

import 'package:sisonke/features/checkin/services/trigger_pattern_service.dart';

// ─── Mood insights helpers ────────────────────────────────────────────────────

/// Returns 0 (great) … 5 (overwhelmed) — higher = harder mood
int _moodOrdinal(MoodType m) => MoodType.values.indexOf(m);

/// True for positive moods (great / okay)
bool _isPositive(MoodType m) => m == MoodType.great || m == MoodType.okay;

/// True for difficult moods
bool _isDifficult(MoodType m) =>
    m == MoodType.low ||
    m == MoodType.anxious ||
    m == MoodType.overwhelmed ||
    m == MoodType.angry;

class _MoodInsights {
  final String bestDay;
  final String worstDay;
  final String trend; // "improving", "stable", "declining"

  const _MoodInsights({
    required this.bestDay,
    required this.worstDay,
    required this.trend,
  });
}

_MoodInsights _computeInsights(List<MoodEntry> entries) {
  final dayPositive = <int, int>{};
  final dayDifficult = <int, int>{};
  for (final e in entries) {
    final wd = e.timestamp.weekday;
    dayPositive[wd] = (dayPositive[wd] ?? 0) + (_isPositive(e.mood) ? 1 : 0);
    dayDifficult[wd] =
        (dayDifficult[wd] ?? 0) + (_isDifficult(e.mood) ? 1 : 0);
  }
  const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String bestDay = 'Fri';
  int bestCount = -1;
  for (final kv in dayPositive.entries) {
    if (kv.value > bestCount) {
      bestCount = kv.value;
      bestDay = dayNames[kv.key];
    }
  }
  String worstDay = 'Mon';
  int worstCount = -1;
  for (final kv in dayDifficult.entries) {
    if (kv.value > worstCount) {
      worstCount = kv.value;
      worstDay = dayNames[kv.key];
    }
  }

  final sorted = [...entries]
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  double firstAvg = 0;
  double lastAvg = 0;
  if (sorted.length >= 6) {
    final first3 = sorted.take(3).map((e) => _moodOrdinal(e.mood));
    final last3 = sorted.reversed.take(3).map((e) => _moodOrdinal(e.mood));
    firstAvg = first3.reduce((a, b) => a + b) / 3;
    lastAvg = last3.reduce((a, b) => a + b) / 3;
  }
  String trend;
  if (lastAvg < firstAvg - 0.4) {
    trend = 'improving';
  } else if (lastAvg > firstAvg + 0.4) {
    trend = 'declining';
  } else {
    trend = 'stable';
  }

  return _MoodInsights(bestDay: bestDay, worstDay: worstDay, trend: trend);
}

// ─── Insights panel widget ────────────────────────────────────────────────────
class _InsightsPanel extends StatelessWidget {
  final List<MoodEntry> entries;
  const _InsightsPanel({required this.entries});

  @override
  Widget build(BuildContext context) {
    final insights = _computeInsights(entries);
    final analysis = TriggerPatternService.analyze(entries);

    final trendIcon =
        insights.trend == 'improving' ? '↑' : (insights.trend == 'declining' ? '↓' : '→');
    final trendLabel =
        insights.trend == 'improving'
            ? 'Improving'
            : (insights.trend == 'declining' ? 'Needs Care' : 'Stable');
    final trendColor =
        insights.trend == 'improving'
            ? SisonkeColors.riskLow
            : (insights.trend == 'declining'
                ? SisonkeColors.riskHigh
                : SisonkeColors.riskMedium);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCA0174).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCA0174).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.radar_rounded,
                      size: 18,
                      color: Color(0xFFCA0174),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recognised Triggers & Patterns',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F3433),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF921966).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Serevo AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF921966),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Overview 3 Stat Chips
          Row(
            children: [
              _StatChip(
                label: 'Best Day',
                value: insights.bestDay,
                color: SisonkeColors.riskLow,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Heaviest Day',
                value: insights.worstDay,
                color: SisonkeColors.riskMedium,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Trend',
                value: '$trendIcon $trendLabel',
                color: trendColor,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Recognised Triggers breakdown ──
          if (analysis.topTriggers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFCA0174)),
                      const SizedBox(width: 6),
                      const Text(
                        'Detected Triggers',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2F3433),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: analysis.topTriggers.take(4).map((trig) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: trig.difficultCount > 0
                                ? const Color(0xFFCA0174).withValues(alpha: 0.3)
                                : Colors.black12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              trig.tag,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2F3433),
                              ),
                            ),
                            if (trig.totalCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: trig.difficultCount > 0
                                      ? const Color(0xFFCA0174).withValues(alpha: 0.15)
                                      : const Color(0xFF1BB9B9).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${trig.totalCount}x',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: trig.difficultCount > 0
                                        ? const Color(0xFFCA0174)
                                        : const Color(0xFF1B75B9),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (analysis.topTriggers.first.suggestion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '💡 Serevo recommendation: ${analysis.topTriggers.first.suggestion}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: const Color(0xFF2F3433).withValues(alpha: 0.75),
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Cyclical Patterns (Time of Day & Day of Week) ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF1B75B9)),
                    const SizedBox(width: 6),
                    const Text(
                      'Cyclical Rhythms',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F3433),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '• ${analysis.timeOfDayInsight}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: const Color(0xFF2F3433).withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${analysis.dayOfWeekInsight}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: const Color(0xFF2F3433).withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${analysis.energyInsight}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: const Color(0xFF2F3433).withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha:0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha:0.75),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: const SisonkeAppBar(
        title: 'Emotional History',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: SisonkeColors.forestBreeze,
        ),
        child: moods.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha:0.4)),
                        ),
                        child: const Icon(Icons.spa_outlined, size: 64, color: Color(0xFF2E6F60)),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No reflections captured yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3433),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your path starts here. Take a moment to reflect on your emotional weather today.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF2F3433).withValues(alpha:0.6),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SisonkeButton(
                        onPressed: () => context.push('/check-in/reflection'),
                        label: 'Check-in Now',
                        icon: Icons.favorite_outline_rounded,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: moods.length + 1,
                itemBuilder: (context, index) {
                  // Slot 0: insights & trigger patterns panel
                  if (index == 0) {
                    return _InsightsPanel(entries: moods);
                  }
                  final entry = moods[index - 1];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.72),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha:0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              entry.mood.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.mood.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2F3433),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      size: 13,
                                      color: const Color(0xFF2F3433).withValues(alpha:0.5),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM dd • hh:mm a').format(entry.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFF2F3433).withValues(alpha:0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                if (entry.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: entry.tags.map((t) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCA0174).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFCA0174).withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFCA0174),
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ],
                                if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha:0.4),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      entry.note!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF2F3433).withValues(alpha:0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E6F60).withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.flash_on_rounded, size: 14, color: Color(0xFF2E6F60)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${entry.energyLevel}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2E6F60),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/check-in/reflection'),
        backgroundColor: const Color(0xFF2E6F60),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Reflection', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }
}
