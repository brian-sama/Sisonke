import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/features/checkin/providers/mood_provider.dart';
import 'package:sisonke/features/checkin/services/trigger_pattern_service.dart';
import 'package:sisonke/shared/models/mood.dart';
import 'package:sisonke/shared/widgets/emergency_help_button.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _nickname = '';
  int _activeHeroIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nickname = prefs.getString('user_nickname') ?? 'Samantha';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;
    final displayName = _nickname.isNotEmpty ? _nickname : 'Friend';
    final moods = ref.watch(moodEntriesProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF14110E) : const Color(0xFFFAF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (Hello, Name + Avatar + Bell + Calendar) ────
              _buildTopHeader(context, displayName, isDark, primaryTextColor),

              const SizedBox(height: 22),

              // ── Hero Carousel Cards (Keep your head up + Mascots) ──
              _buildHeroCarousel(context, isDark),

              const SizedBox(height: 24),

              // ── Ubuntu Circles Link Card (Umuntu ngumuntu ngabantu) ─
              _buildUbuntuCirclesCard(context, isDark),

              const SizedBox(height: 24),

              // ── More Than Words (Photos & Videos • 50MB Limit) ──────
              _buildMoreThanWordsCard(context, isDark),

              const SizedBox(height: 24),

              // ── Recognised Triggers & Patterns Card ────────────────
              _buildRecognisedTriggersAndPatternsCard(context, isDark, moods),

              const SizedBox(height: 26),

              // ── Your week at a glance (Mood Donut + Energy & Stress) ─
              _buildWeekAtAGlance(context, isDark),

              const SizedBox(height: 28),

              // ── Featured Facilitator Card (How do I stop overthinking)
              _buildFeaturedFacilitatorCard(context, isDark),

              const SizedBox(height: 32),

              // ── 2-Column Action Grid (From Smart Action Grid Design) 
              _buildActionGrid(context, isDark),
            ],
          ),
        ),
      ),
      floatingActionButton: EmergencyHelpButton(
        onPressed: () => context.push('/emergency'),
      ),
    );
  }

  // ── 1. Top Header ───────────────────────────────────────────────────
  Widget _buildTopHeader(
    BuildContext context,
    String displayName,
    bool isDark,
    Color primaryTextColor,
  ) {
    final buttonBg = isDark ? const Color(0xFF241E1A) : Colors.white;
    final buttonBorder = isDark ? const Color(0xFF382E28) : const Color(0xFFF0E7DE);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Avatar + "Hello, Name" (tap to open Profile & Safety)
        InkWell(
          onTap: () => context.push('/profile-safety'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCA0174).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('🌸', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Right: Notification Bell, Calendar & Settings Buttons
        Row(
          children: [
            _buildRoundHeaderButton(
              icon: Icons.notifications_none_rounded,
              bg: buttonBg,
              border: buttonBorder,
              onTap: () => context.push('/notifications'),
              badge: true,
            ),
            const SizedBox(width: 8),
            _buildRoundHeaderButton(
              icon: Icons.calendar_today_rounded,
              bg: buttonBg,
              border: buttonBorder,
              onTap: () => context.push('/check-in/mood'),
            ),
            const SizedBox(width: 8),
            _buildRoundHeaderButton(
              icon: Icons.settings_outlined,
              bg: buttonBg,
              border: buttonBorder,
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundHeaderButton({
    required IconData icon,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFFFF7A3D)),
            if (badge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 2. Hero Carousel Cards ──────────────────────────────────────────
  Widget _buildHeroCarousel(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView(
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => setState(() => _activeHeroIndex = index),
            children: [
              // Card 1: Warm Apricot "Keep your head up." + Smiling Star Mascot
              _buildHeroCard(
                context: context,
                tag: 'Self Care',
                title: 'Keep your\nhead up.',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFA770), Color(0xFFFF7235)],
                ),
                mascot: const _SmilingStarMascot(size: 110),
                onTap: () => context.push('/breathing'),
              ),

              // Card 2: Soft Lilac "You are not alone." + Soft Cloud Mascot
              _buildHeroCard(
                context: context,
                tag: 'Feelix & Felicia',
                title: 'We are here\nto listen.',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC4B5FD), Color(0xFFA78BFA)],
                ),
                mascot: const _SmilingCloudMascot(size: 110),
                onTap: () => context.go('/e-friend'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (i) {
            final isActive = _activeHeroIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFF7A3D)
                    : (isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroCard({
    required BuildContext context,
    required String tag,
    required String title,
    required Gradient gradient,
    required Widget mascot,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A3D).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Mascot positioned on the left/center
          Positioned(
            left: 14,
            bottom: 12,
            child: mascot,
          ),

          // Content on the right
          Positioned(
            top: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tag pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF7A3D),
                    ),
                  ),
                ),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    color: Colors.white,
                  ),
                ),

                // Arrow circle button
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Your week at a glance ────────────────────────────────────────
  Widget _buildWeekAtAGlance(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF221C18) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF382E28) : const Color(0xFFF2E7DC);
    final textDark = isDark ? Colors.white : SisonkeColors.charcoal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your week at a glance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
            color: textDark,
          ),
        ),
        const SizedBox(height: 14),

        // Mood Donut Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Watercolor Donut Arc
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _WatercolorDonutPainter(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Mood',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textDark.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calm',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDDF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'TOP MOOD',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Color(0xFFFF7A3D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Side-by-side Metric Pills: Energy & Stress
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Energy',
                value: '80',
                isDark: isDark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                accentColor: const Color(0xFFFF7A3D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                label: 'Stress',
                value: '67',
                isDark: isDark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                accentColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color accentColor,
  }) {
    final textDark = isDark ? Colors.white : SisonkeColors.charcoal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textDark.withValues(alpha: 0.65),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Featured Facilitator / Reflection Card ────────────────────────
  Widget _buildFeaturedFacilitatorCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF221C18) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF382E28) : const Color(0xFFF2E7DC);
    final textDark = isDark ? Colors.white : SisonkeColors.charcoal;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Facilitator Header
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFEDDF),
                child: Text('🌱', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gregory Dickinson',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    Text(
                      'Counselor & Facilitator',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: textDark.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert_rounded, color: textDark.withValues(alpha: 0.4)),
            ],
          ),

          const SizedBox(height: 18),

          // Big Inspiring Question (tap to open Resources Library)
          InkWell(
            onTap: () => context.push('/resources'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'How do I stop overthinking at night?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        height: 1.2,
                        color: textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: textDark.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Metadata row + Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: textDark.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    '23 Minutes',
                    style: TextStyle(fontSize: 12, color: textDark.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.menu_book_rounded, size: 14, color: textDark.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    'Library',
                    style: TextStyle(fontSize: 12, color: textDark.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildCircleAction(
                    icon: Icons.bookmark_border_rounded,
                    onTap: () => context.push('/bookmarks'),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildCircleAction(
                    icon: Icons.question_answer_outlined,
                    onTap: () => context.push('/qa'),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildCircleAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () => context.go('/e-friend'),
                    isDark: isDark,
                    filled: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool filled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFFFF7A3D).withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF2C241F) : const Color(0xFFFAF7F2)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? const Color(0xFFFF7A3D) : (isDark ? Colors.white60 : Colors.black45),
        ),
      ),
    );
  }

  // ── 5. 2-Column Action Grid (From Smart Action Grid Design) ──────────
  Widget _buildActionGrid(BuildContext context, bool isDark) {
    final textDark = isDark ? Colors.white : SisonkeColors.charcoal;

    final items = [
      _ActionCardData(
        title: 'Feelix & Felicia',
        subtitle: 'Talk with AI companions',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        icon: Icons.chat_bubble_outline_rounded,
        onTap: () => context.go('/e-friend'),
      ),
      _ActionCardData(
        title: 'Mood Check-in',
        subtitle: 'Log how you feel',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        icon: Icons.spa_outlined,
        onTap: () => context.go('/check-in/mood'),
      ),
      _ActionCardData(
        title: 'Calm Breathing',
        subtitle: '2-minute box reset',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
        ),
        icon: Icons.air_rounded,
        onTap: () => context.push('/breathing'),
      ),
      _ActionCardData(
        title: 'Daily Journal',
        subtitle: 'Reflect & gratitude',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        icon: Icons.edit_note_rounded,
        onTap: () => context.push('/check-in/journal'),
      ),
      _ActionCardData(
        title: 'Ubuntu Circles',
        subtitle: 'Safe peer sanctuaries',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCA0174), Color(0xFF921966)],
        ),
        icon: Icons.diversity_3_outlined,
        onTap: () => context.push('/circles'),
      ),
      _ActionCardData(
        title: 'More Than Words',
        subtitle: 'Photo & video aura (50MB)',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1BB9B9), Color(0xFF1B75B9)],
        ),
        icon: Icons.photo_library_outlined,
        onTap: () => context.push('/more-than-words'),
      ),
      _ActionCardData(
        title: 'Crisis Helpline',
        subtitle: 'Immediate safety',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        icon: Icons.shield_outlined,
        onTap: () => context.push('/emergency'),
      ),
      _ActionCardData(
        title: 'Settings & Security',
        subtitle: 'Biometrics & lock PIN',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF64748B), Color(0xFF475569)],
        ),
        icon: Icons.fingerprint_rounded,
        onTap: () => context.push('/profile-safety'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you want to explore?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
            color: textDark,
          ),
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final card = items[index];
            return InkWell(
              onTap: card.onTap,
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: card.gradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Left Icon Container + Right Diagonal Arrow ↗
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(card.icon, size: 20, color: Colors.white),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    // Bottom: Title & Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.82),
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
      ],
    );
  }

  // ── Ubuntu Circles Sanctuary Link Card ──────────────────────────────
  Widget _buildUbuntuCirclesCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF241E1A) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF382E28) : const Color(0xFFF0E7DE);
    final textDark = isDark ? Colors.white : SisonkeColors.charcoal;

    return InkWell(
      onTap: () => context.push('/circles'),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCA0174).withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFCA0174), Color(0xFF921966)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCA0174).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.diversity_3_rounded, size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubuntu Circles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Umuntu ngumuntu ngabantu',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFCA0174),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCA0174).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SAFE PEER SPACE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFFCA0174),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              'You do not have to carry everything alone. Join anonymous peer circles to share, heal, and find quiet comfort together.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: textDark.withValues(alpha: 0.72),
              ),
            ),

            const SizedBox(height: 14),

            // Active Circle Topics
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildCircleTopicChip('🕊️ Grief & Loss', isDark),
                _buildCircleTopicChip('🎓 Exam Stress', isDark),
                _buildCircleTopicChip('⛈️ Anxiety', isDark),
                _buildCircleTopicChip('🌱 Sobriety', isDark),
                _buildCircleTopicChip('🫂 Loneliness', isDark),
              ],
            ),

            const SizedBox(height: 16),

            // Join Button Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFCA0174).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore All Circles & Topics',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFCA0174),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFCA0174)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleTopicChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2421) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF453630) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFF0E5DF) : const Color(0xFF2F3433),
        ),
      ),
    );
  }

  // ── More Than Words Non-Verbal Sanctuary Card ────────────────────────
  Widget _buildMoreThanWordsCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF241E1A) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF382E28) : const Color(0xFFF0E7DE);
    final textDark = isDark ? Colors.white : SisonkeColors.charcoal;

    return InkWell(
      onTap: () => context.push('/more-than-words'),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1BB9B9).withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1BB9B9), Color(0xFF1B75B9)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1BB9B9).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.photo_library_rounded, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'More Than Words',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Visual Non-Verbal Sanctuary',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B75B9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1BB9B9).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '50MB UPLOAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFF1B75B9),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              'When words are too heavy or simply not enough. Express your state through photos and quiet video clips without having to explain yourself.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: textDark.withValues(alpha: 0.72),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _buildTagPill(icon: Icons.image_outlined, label: 'Photos', isDark: isDark),
                const SizedBox(width: 8),
                _buildTagPill(icon: Icons.videocam_outlined, label: 'Videos (50MB)', isDark: isDark),
                const SizedBox(width: 8),
                _buildTagPill(icon: Icons.favorite_border_rounded, label: 'Holding Space', isDark: isDark),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1BB9B9).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enter Visual Sanctuary',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B75B9),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF1B75B9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPill({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2833) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A4D) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF1B75B9)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFE2EAF2) : const Color(0xFF2F3433),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recognised Triggers & Patterns Card ──────────────────────────────
  Widget _buildRecognisedTriggersAndPatternsCard(
    BuildContext context,
    bool isDark,
    List<MoodEntry> moods,
  ) {
    final cardBg = isDark ? const Color(0xFF241E1A) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF382E28) : const Color(0xFFF0E7DE);
    final textDark = isDark ? Colors.white : SisonkeColors.charcoal;
    final analysis = TriggerPatternService.analyze(moods);

    return InkWell(
      onTap: () => context.push('/check-in/mood'),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDA737).withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFDA737), Color(0xFFF7584B)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFDA737).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.radar_rounded, size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recognised Triggers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Cyclical Rhythms & Patterns',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF76844),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDA737).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SEREVO AI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFFD3155F),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Top Detected Triggers Chips
            Text(
              'Identified Emotional Triggers:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: analysis.topTriggers.take(3).map((trig) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E221A) : const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: trig.difficultCount > 0
                          ? const Color(0xFFCA0174).withValues(alpha: 0.3)
                          : (isDark ? const Color(0xFF45352A) : Colors.black12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trig.tag,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFF5E7DF) : const Color(0xFF2F3433),
                        ),
                      ),
                      if (trig.totalCount > 0) ...[
                        const SizedBox(width: 5),
                        Text(
                          '${trig.totalCount}x',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFCA0174),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Pattern Rhythms (Time & Day)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2019) : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF3D2F25) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insights_rounded, size: 14, color: Color(0xFF1B75B9)),
                      const SizedBox(width: 6),
                      Text(
                        'Cyclical Pattern Insight',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    analysis.timeOfDayInsight,
                    style: TextStyle(
                      fontSize: 12,
                      color: textDark.withValues(alpha: 0.75),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '💡 Serevo recommendation: ${analysis.topTriggers.isNotEmpty ? analysis.topTriggers.first.suggestion : analysis.timeOfDaySuggestion}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF921966),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDA737).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Full Emotional History & Analysis',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF921966),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF921966)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Models & Custom Mascot Painters ───────────────────────────────────

class _ActionCardData {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCardData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });
}

// ── Smiling Star Mascot from Design Revamp ─────────────────────────────
class _SmilingStarMascot extends StatelessWidget {
  final double size;
  const _SmilingStarMascot({this.size = 100});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SmilingStarPainter(),
    );
  }
}

class _SmilingStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;

    // Body paint (warm golden pastel yellow)
    final starPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;

    // Soft warm shadow/gradient aura
    final shadowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Draw rounded star / flower body
    final path = Path()
      ..moveTo(50 * scale, 10 * scale)
      ..cubicTo(60 * scale, 25 * scale, 75 * scale, 25 * scale, 90 * scale, 38 * scale)
      ..cubicTo(82 * scale, 55 * scale, 86 * scale, 72 * scale, 75 * scale, 88 * scale)
      ..cubicTo(60 * scale, 80 * scale, 40 * scale, 80 * scale, 25 * scale, 88 * scale)
      ..cubicTo(14 * scale, 72 * scale, 18 * scale, 55 * scale, 10 * scale, 38 * scale)
      ..cubicTo(25 * scale, 25 * scale, 40 * scale, 25 * scale, 50 * scale, 10 * scale)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, starPaint);

    // Dark facial features
    final facePaint = Paint()
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.fill;

    // Eyes
    canvas.drawCircle(Offset(40 * scale, 50 * scale), 3.0 * scale, facePaint);
    canvas.drawCircle(Offset(58 * scale, 50 * scale), 3.0 * scale, facePaint);

    // Rosy cheeks
    final blushPaint = Paint()
      ..color = const Color(0xFFFB7185).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(34 * scale, 56 * scale), 4.5 * scale, blushPaint);
    canvas.drawCircle(Offset(64 * scale, 56 * scale), 4.5 * scale, blushPaint);

    // Smiling mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(45 * scale, 58 * scale)
      ..quadraticBezierTo(49 * scale, 63 * scale, 53 * scale, 58 * scale);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Smiling Cloud Mascot from Design Revamp ────────────────────────────
class _SmilingCloudMascot extends StatelessWidget {
  final double size;
  const _SmilingCloudMascot({this.size = 100});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SmilingCloudPainter(),
    );
  }
}

class _SmilingCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;

    final bodyPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    // Draw fluffy cloud
    canvas.drawCircle(Offset(32 * scale, 55 * scale), 20 * scale, bodyPaint);
    canvas.drawCircle(Offset(52 * scale, 42 * scale), 24 * scale, bodyPaint);
    canvas.drawCircle(Offset(70 * scale, 56 * scale), 18 * scale, bodyPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(26 * scale, 52 * scale, 50 * scale, 22 * scale),
        Radius.circular(12 * scale),
      ),
      bodyPaint,
    );

    // Eyes (curved happy eyes)
    final eyeStroke = Paint()
      ..color = const Color(0xFF4C1D95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round;

    final leftEye = Path()
      ..moveTo(42 * scale, 50 * scale)
      ..quadraticBezierTo(46 * scale, 46 * scale, 50 * scale, 50 * scale);
    final rightEye = Path()
      ..moveTo(56 * scale, 50 * scale)
      ..quadraticBezierTo(60 * scale, 46 * scale, 64 * scale, 50 * scale);
    canvas.drawPath(leftEye, eyeStroke);
    canvas.drawPath(rightEye, eyeStroke);

    // Smile
    final mouth = Path()
      ..moveTo(51 * scale, 56 * scale)
      ..quadraticBezierTo(54 * scale, 60 * scale, 57 * scale, 56 * scale);
    canvas.drawPath(mouth, eyeStroke);

    // Blush
    final blush = Paint()
      ..color = const Color(0xFFF472B6).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(38 * scale, 53 * scale), 4 * scale, blush);
    canvas.drawCircle(Offset(68 * scale, 53 * scale), 4 * scale, blush);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Watercolor Mood Donut Painter ──────────────────────────────────────
class _WatercolorDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 18.0;

    final segments = [
      {'color': const Color(0xFFFFA570), 'sweep': 1.6}, // Apricot (Calm)
      {'color': const Color(0xFFC4B5FD), 'sweep': 1.4}, // Lilac (Reflective)
      {'color': const Color(0xFFFDE047), 'sweep': 1.2}, // Yellow (Joyful)
      {'color': const Color(0xFF6EE7B7), 'sweep': 2.0}, // Mint (Balanced)
    ];

    var startAngle = -1.57; // -pi/2
    for (final seg in segments) {
      final paint = Paint()
        ..color = seg['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweep = seg['sweep'] as double;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep - 0.15,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
