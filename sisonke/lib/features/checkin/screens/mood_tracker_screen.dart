import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/features/mood_tracker/providers/mood_provider.dart';
import 'package:sisonke/features/checkin/screens/mood_checkin_screen.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

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
  // ── Day of week analysis ─────────────────────────────────────────────────
  // dayPositive[weekday] = count of positive entries on that day (1=Mon…7=Sun)
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

  // ── 7-day trend: compare first 3 vs last 3 by ordinal ────────────────────
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
  // Lower ordinal = better mood, so lastAvg < firstAvg means improving
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
    final trendIcon =
        insights.trend == 'improving' ? '↑' : (insights.trend == 'declining' ? '↓' : '→');
    final trendLabel =
        insights.trend == 'improving'
            ? 'Improving'
            : (insights.trend == 'declining' ? 'Watch this' : 'Stable');
    final trendColor =
        insights.trend == 'improving'
            ? SisonkeColors.riskLow
            : (insights.trend == 'declining'
                ? SisonkeColors.riskHigh
                : SisonkeColors.riskMedium);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha:0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your patterns',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xFF2F3433).withValues(alpha:0.5),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatChip(
                label: 'Best',
                value: insights.bestDay,
                color: SisonkeColors.riskLow,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Needs care',
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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MoodCheckinScreen()),
                        ),
                        label: 'Check-in Now',
                        icon: Icons.favorite_outline_rounded,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: moods.length + (moods.length >= 7 ? 1 : 0),
                itemBuilder: (context, index) {
                  // Slot 0: insights panel when 7+ entries exist
                  if (moods.length >= 7 && index == 0) {
                    return _InsightsPanel(entries: moods);
                  }
                  final entryIndex = moods.length >= 7 ? index - 1 : index;
                  final entry = moods[entryIndex];
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoodCheckinScreen()),
        ),
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
