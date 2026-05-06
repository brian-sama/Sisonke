import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/features/mood_tracker/providers/mood_provider.dart';
import 'package:sisonke/features/checkin/screens/mood_checkin_screen.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

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
                          color: Colors.white.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
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
                          color: const Color(0xFF2F3433).withOpacity(0.6),
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
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final entry = moods[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
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
                              color: Colors.white.withOpacity(0.8),
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
                                      color: const Color(0xFF2F3433).withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM dd • hh:mm a').format(entry.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFF2F3433).withOpacity(0.6),
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
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      entry.note!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF2F3433).withOpacity(0.8),
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
                                  color: const Color(0xFF2E6F60).withOpacity(0.1),
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
