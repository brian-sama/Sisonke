import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/services/widget_service.dart';
import 'package:sisonke/features/journal/providers/journal_provider.dart';
import 'package:sisonke/features/mood_tracker/providers/mood_provider.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  final int? entryId;
  final String? mode;
  const JournalEntryScreen({super.key, this.entryId, this.mode});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLocked = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'gratitude') {
      _titleController.text = 'Gratitude Jar Entry';
    } else if (widget.mode == 'worry') {
      _titleController.text = 'Worry Dump Entry';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFD68A7F),
          content: Text(
            'Your heart is full of thoughts. Write something to save.',
          ),
        ),
      );
      return;
    }

    if (widget.mode == 'worry') {
      // Trigger Worry Box folding and dropping animation sequence
      setState(() => _isAnimating = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // Prompt with the comforting "let it go" question
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: SisonkeColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'Letting go...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F3433),
            ),
          ),
          content: const Text(
            'Your worry has been folded and securely locked inside the Worry Box. Would you like to let this go for tonight?',
            style: TextStyle(color: Color(0xFF2F3433)),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _persistEntry();
              },
              child: const Text('Keep in journal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E6F60),
              ),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _persistEntry(letGo: true);
              },
              child: const Text(
                'Yes, let it go',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (widget.mode == 'gratitude') {
      // Trigger Gratitude Jar glowing star rise animation sequence
      setState(() => _isAnimating = true);
      await Future.delayed(const Duration(milliseconds: 2000));
      await _persistEntry(isGratitude: true);
    } else {
      await _persistEntry();
    }
  }

  Future<void> _persistEntry({
    bool letGo = false,
    bool isGratitude = false,
  }) async {
    final modeTag = widget.mode ?? 'free';
    await ref
        .read(journalEntriesProvider.notifier)
        .addEntry(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          isLocked: _isLocked,
          tags: [modeTag],
        );

    // Sync to native home widgets
    try {
      final journals = ref.read(journalEntriesProvider);
      final gratitudeCount = journals
          .where((j) => j.tags.contains('gratitude'))
          .length;

      final moods = ref.read(moodEntriesProvider);
      final latestMood = moods.isNotEmpty ? moods.first.mood : MoodType.okay;

      await WidgetService.syncSnapshot(
        WidgetService.snapshotForMood(
          mood: latestMood,
          gratitudeStars: gratitudeCount,
        ),
      );
    } catch (e) {
      debugPrint('Failed to sync widget after journal entry: $e');
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2E6F60),
          content: Text(
            letGo
                ? 'Worry released. Take a slow, comforting breath tonight.'
                : (isGratitude
                      ? 'Your memory has been added to the Gratitude Jar!'
                      : 'Journal entry saved!'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 'gratitude') {
      return _buildGratitudeJarLayout();
    }
    if (widget.mode == 'worry') {
      return _buildWorryBoxLayout();
    }

    return Scaffold(
      appBar: SisonkeAppBar(
        title: widget.entryId == null ? 'New Reflection' : 'Edit Reflection',
        actions: [
          IconButton(
            onPressed: _saveEntry,
            icon: const Icon(Icons.check_rounded, color: Color(0xFF2E6F60)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: SisonkeColors.forestBreeze),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Reflection Title',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3433),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts freely here...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2F3433),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isLocked,
                  title: const Text(
                    'Lock with Sisonke PIN?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3433),
                    ),
                  ),
                  onChanged: (value) => setState(() => _isLocked = value),
                ),
              ),
              const SizedBox(height: 24),
              SisonkeButton(
                onPressed: _saveEntry,
                label: 'Save Entry',
                icon: Icons.check_circle_outline_rounded,
                isFullWidth: true,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🏺 Gratitude Jar Layout ---
  Widget _buildGratitudeJarLayout() {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Gratitude Jar'),
      body: Container(
        decoration: const BoxDecoration(gradient: SisonkeColors.forestBreeze),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: _GratitudeJarAnimator(isAnimating: _isAnimating),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'What is a memory you are grateful for today?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3433),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          enabled: !_isAnimating,
                          decoration: InputDecoration(
                            hintText:
                                'A warm conversation, sunlight on your desk, or a small victory...',
                            fillColor: Colors.white.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SisonkeButton(
                        onPressed: _saveEntry,
                        isEnabled: !_isAnimating,
                        label: _isAnimating
                            ? 'Adding Memory...'
                            : 'Drop Memory into Jar',
                        icon: Icons.favorite_rounded,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 📦 Worry Box Layout ---
  Widget _buildWorryBoxLayout() {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Worry Box'),
      body: Container(
        decoration: const BoxDecoration(gradient: SisonkeColors.pastelSunset),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: _WorryBoxAnimator(isAnimating: _isAnimating),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Empty your mind of worries here.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3433),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can fold them up and drop them away for the night.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(
                            0xFF2F3433,
                          ).withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 600),
                          opacity: _isAnimating ? 0.0 : 1.0,
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            enabled: !_isAnimating,
                            decoration: InputDecoration(
                              hintText:
                                  'What is weighing on your chest right now?',
                              fillColor: Colors.white.withValues(alpha: 0.6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SisonkeButton(
                        onPressed: _saveEntry,
                        isEnabled: !_isAnimating,
                        label: _isAnimating
                            ? 'Folding Letter...'
                            : 'Release and Let Go',
                        icon: Icons.delete_outline_rounded,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 🏺 Stateful Gratitude Jar Interactive Vector Animation ---
class _GratitudeJarAnimator extends StatefulWidget {
  final bool isAnimating;
  const _GratitudeJarAnimator({required this.isAnimating});

  @override
  State<_GratitudeJarAnimator> createState() => _GratitudeJarAnimatorState();
}

class _GratitudeJarAnimatorState extends State<_GratitudeJarAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  final List<Offset> _starsInJar = [
    const Offset(-15, 30),
    const Offset(15, 10),
    const Offset(-5, -10),
    const Offset(20, 40),
    const Offset(-20, 15),
  ];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didUpdateWidget(covariant _GratitudeJarAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating) {
      _starController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        final progress = _starController.value;
        // Calculation for the flying star particle
        final startY = 180.0;
        final endY = -10.0;
        final currentY = startY + (endY - startY) * progress;
        final waveX = math.sin(progress * math.pi * 3) * 35 * (1.0 - progress);
        final starOpacity = progress > 0.0 && progress < 0.9 ? 1.0 : 0.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // The Glass Jar outline container
            Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(45),
                  bottomRight: Radius.circular(45),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  // Metallic jar lid
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 90,
                      height: 18,
                      decoration: BoxDecoration(
                        color: SisonkeColors.lemon,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // Glow stars already inside the jar
                  ..._starsInJar.map((offset) {
                    return Positioned(
                      left: 70 + offset.dx,
                      top: 90 + offset.dy,
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF7E8B5), // lemon glow
                        size: 16,
                      ),
                    );
                  }),
                  // Conditionally add the new star when animation completes
                  if (progress >= 0.85)
                    const Positioned(
                      left: 70,
                      top: 70,
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF7E8B5),
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
            // The Flying Star Memory particle rising upwards
            if (widget.isAnimating)
              Transform.translate(
                offset: Offset(waveX, currentY),
                child: Opacity(
                  opacity: starOpacity,
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF7E8B5),
                    size: 28,
                    shadows: [Shadow(color: Colors.white, blurRadius: 12)],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// --- 📦 Stateful Worry Box Folding Origami Letter Animation ---
class _WorryBoxAnimator extends StatefulWidget {
  final bool isAnimating;
  const _WorryBoxAnimator({required this.isAnimating});

  @override
  State<_WorryBoxAnimator> createState() => _WorryBoxAnimatorState();
}

class _WorryBoxAnimatorState extends State<_WorryBoxAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _foldController;

  @override
  void initState() {
    super.initState();
    _foldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didUpdateWidget(covariant _WorryBoxAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating) {
      _foldController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _foldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _foldController,
      builder: (context, child) {
        final progress = _foldController.value;

        // Sequence of paper collapse, rotation, drop, and fadeout
        final rotation = progress * math.pi * 1.5;
        final scale = 1.0 - (progress * 0.7);
        final dropY = progress < 0.3 ? 0.0 : (progress - 0.3) * 200.0;
        final opacity = progress < 0.85 ? 1.0 : (1.0 - progress) * 6.6;

        return Stack(
          alignment: Alignment.center,
          children: [
            // The Wooden Worry Chest Outline Vector
            Container(
              width: 150,
              height: 130,
              margin: const EdgeInsets.only(top: 100),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B9A2), // Clay style
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            // The folding letter sheet
            if (widget.isAnimating)
              Transform.translate(
                offset: Offset(0, -50 + dropY),
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD68A7F),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.mail_outline_rounded,
                              color: Color(0xFFD68A7F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
