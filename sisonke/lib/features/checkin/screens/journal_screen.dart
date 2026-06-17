import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/features/journal/providers/journal_provider.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/features/checkin/screens/journal_entry_screen.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

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

  // ── Gratitude streak helpers ──────────────────────────────────────────────
  static const _streakCountKey = 'gratitude_streak_count';
  static const _streakLastDateKey = 'gratitude_last_date';

  Future<int> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_streakLastDateKey);
    if (lastDateStr == null) return 0;
    final lastDate = DateTime.parse(lastDateStr);
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final lastNorm = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final diff = todayNorm.difference(lastNorm).inDays;
    if (diff == 0 || diff == 1) {
      return prefs.getInt(_streakCountKey) ?? 1;
    }
    // streak broken — reset
    await prefs.setInt(_streakCountKey, 0);
    await prefs.remove(_streakLastDateKey);
    return 0;
  }

  /// Called when the user saves a new entry.
  Future<void> _recordStreakEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_streakLastDateKey);
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    if (lastDateStr == null) {
      await prefs.setInt(_streakCountKey, 1);
      await prefs.setString(_streakLastDateKey, todayNorm.toIso8601String());
      return;
    }

    final lastDate = DateTime.parse(lastDateStr);
    final lastNorm =
        DateTime(lastDate.year, lastDate.month, lastDate.day);
    final diff = todayNorm.difference(lastNorm).inDays;

    if (diff == 0) {
      // already logged today — no change
      return;
    } else if (diff == 1) {
      // consecutive day
      final current = prefs.getInt(_streakCountKey) ?? 1;
      await prefs.setInt(_streakCountKey, current + 1);
      await prefs.setString(_streakLastDateKey, todayNorm.toIso8601String());
    } else {
      // gap — reset
      await prefs.setInt(_streakCountKey, 1);
      await prefs.setString(_streakLastDateKey, todayNorm.toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalEntriesProvider);
    final securityService = ref.read(securityServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: Column(
        children: [
          // ── Gratitude streak banner ────────────────────────────────────
          FutureBuilder<int>(
            future: _loadStreak(),
            builder: (context, snap) {
              final streak = snap.data ?? 0;
              if (streak < 1) return const SizedBox.shrink();
              final emoji =
                  streak >= 30 ? '🌳' : (streak >= 7 ? '🌻' : '🌱');
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: SisonkeColors.primaryDim,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        '$streak-day gratitude streak',
                        style: const TextStyle(
                          color: SisonkeColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // ── Main body ─────────────────────────────────────────────────
          Expanded(
            child: entries.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const WellnessIllustrationCard(
                  title: 'Your private journal',
                  body:
                      'Write freely, keep gratitude, empty worries, or reflect with a prompt.',
                  icon: Icons.edit_note_rounded,
                  color: SisonkeColors.lemon,
                ),
                const SizedBox(height: 18),
                const SoftSectionHeader(
                  title: 'What would you like to write?',
                  subtitle:
                      'These modes stay under Journal so it still feels familiar.',
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    _JournalModeCard(
                      title: 'Write Freely',
                      icon: Icons.border_color_rounded,
                      color: SisonkeColors.sky,
                      onTap: () => _openEntry(context, mode: 'free'),
                    ),
                    _JournalModeCard(
                      title: 'Gratitude',
                      icon: Icons.favorite_rounded,
                      color: SisonkeColors.blush,
                      onTap: () => _openEntry(context, mode: 'gratitude'),
                    ),
                    _JournalModeCard(
                      title: 'Worry Dump',
                      icon: Icons.inbox_rounded,
                      color: SisonkeColors.mint,
                      onTap: () => _openEntry(context, mode: 'worry'),
                    ),
                    _JournalModeCard(
                      title: 'Reflect',
                      icon: Icons.lightbulb_rounded,
                      color: SisonkeColors.lavender,
                      onTap: () => _openEntry(context, mode: 'reflect'),
                    ),
                    _JournalModeCard(
                      title: 'Voice Journal',
                      icon: Icons.mic_rounded,
                      color: SisonkeColors.clay,
                      onTap: () => _openEntry(context, mode: 'voice'),
                    ),
                    _JournalModeCard(
                      title: 'Treasure Box',
                      icon: Icons.emoji_events_rounded,
                      color: SisonkeColors.sage,
                      onTap: () => _openEntry(context, mode: 'treasure'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                RoundedPrimaryButton(
                  label: 'Start Writing',
                  icon: Icons.add_rounded,
                  onPressed: () => _openEntry(context),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: AppConstants.spacingMedium,
                  ),
                  child: ListTile(
                    title: Text(entry.title.isEmpty ? 'Untitled' : entry.title),
                    subtitle: Text(
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(entry.createdAt),
                    ),
                    trailing: entry.isLocked
                        ? const Icon(Icons.lock_outline)
                        : null,
                    onTap: () async {
                      if (entry.isLocked) {
                        final authenticated = await securityService
                            .authenticate();
                        if (!authenticated) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Authentication failed'),
                              ),
                            );
                          }
                          return;
                        }
                      }

                      final decryptedContent = await ref
                          .read(journalEntriesProvider.notifier)
                          .getDecryptedContent(entry.content);

                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              entry.title.isEmpty ? 'Untitled' : entry.title,
                            ),
                            content: SingleChildScrollView(
                              child: Text(decryptedContent),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(journalEntriesProvider.notifier)
                                      .deleteEntry(entry.isarId!);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
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
          ), // Expanded
        ],
      ), // Column (body)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEntry(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEntry(BuildContext context, {String? mode}) async {
    if (mode == 'gratitude') {
      await _recordStreakEntry();
    }
    if (!mounted) return;
    Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => JournalEntryScreen(mode: mode)),
    );
  }
}

class _JournalModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _JournalModeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PastelToolCard(
      title: title,
      subtitle: 'Private entry',
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}
