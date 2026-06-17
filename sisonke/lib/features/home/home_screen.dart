import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nickname = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() => _nickname = prefs.getString('user_nickname') ?? '');
      }
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Mangwanani';   // Good morning — Shona
    if (hour >= 12 && hour < 17) return 'Good afternoon'; // English
    return 'Sawubona';                                  // I see you — Ndebele evening greeting
  }

  bool get _isLateNight {
    final hour = DateTime.now().hour;
    return hour >= 22 || hour < 5;
  }

  @override
  Widget build(BuildContext context) {
    final topActionColor =
        Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: SisonkeColors.cream,
      appBar: SisonkeAppBar(
        title: 'Sisonke',
        showBackButton: false,
        backgroundColor: SisonkeColors.cream,
        foregroundColor: SisonkeColors.charcoal,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              color: SisonkeColors.primary,
              tooltip: 'Notifications',
              style: IconButton.styleFrom(
                backgroundColor: topActionColor,
                fixedSize: const Size(40, 40),
              ),
              onPressed: () => context.push('/notifications'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              tooltip: 'Profile menu',
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: topActionColor,
                child: const Icon(
                  Icons.person_rounded,
                  color: SisonkeColors.primary,
                ),
              ),
              onSelected: (value) => context.push(value),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: '/profile-safety',
                  child: Text('Profile & Safety'),
                ),
                PopupMenuItem(value: '/settings', child: Text('Settings')),
                PopupMenuItem(value: '/resources', child: Text('Learn & Grow')),
                PopupMenuItem(
                  value: '/emergency',
                  child: Text('Emergency Support'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLateNight
                        ? 'Still with you  🌙'
                        : '$_greeting${_nickname.isNotEmpty ? ', $_nickname' : ''}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: SisonkeColors.charcoal,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLateNight
                        ? 'It\'s late. Whatever brought you here — you\'re not alone.'
                        : 'What do you need today?',
                    style: TextStyle(
                      fontSize: 15,
                      color: SisonkeColors.charcoal.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── Primary intent cards ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _IntentCard(
                    label: 'Want to talk?',
                    sublabel: 'Sisonke Friend is listening',
                    icon: Icons.chat_bubble_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2E6F60), Color(0xFF1A3D36)],
                    ),
                    foreground: Colors.white,
                    onTap: () => context.go('/e-friend'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _IntentCard(
                    label: 'How are you feeling?',
                    sublabel: 'Check in with yourself',
                    icon: Icons.spa_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEBCBD0), Color(0xFFE4DDF6)],
                    ),
                    foreground: SisonkeColors.charcoal,
                    onTap: () => context.go('/check-in/mood'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Quick tools ─────────────────────────────────────────────────
            Text(
              'Quick tools',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: SisonkeColors.charcoal.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ToolCard(
                    icon: Icons.self_improvement_rounded,
                    label: 'Breathe',
                    subtitle: '2 minutes',
                    color: const Color(0xFFE7FAFA),
                    onTap: () => context.push('/breathing'),
                  ),
                  const SizedBox(width: 10),
                  _ToolCard(
                    icon: Icons.edit_note_rounded,
                    label: 'Gratitude',
                    subtitle: 'One good thing',
                    color: const Color(0xFFFFF6D8),
                    onTap: () =>
                        context.push('/journal-entry?mode=gratitude'),
                  ),
                  const SizedBox(width: 10),
                  _ToolCard(
                    icon: Icons.flag_rounded,
                    label: 'Safety plan',
                    subtitle: 'Plan ahead',
                    color: const Color(0xFFFFEEF0),
                    onTap: () => context.push('/safety-plan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: EmergencyHelpButton(
        onPressed: () => context.push('/emergency'),
      ),
    );
  }
}

// ─── Intent card ─────────────────────────────────────────────────────────────

class _IntentCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Gradient gradient;
  final Color foreground;
  final VoidCallback onTap;

  const _IntentCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.gradient,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: foreground, size: 28),
                const SizedBox(height: 40),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: foreground,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: foreground.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tool card ───────────────────────────────────────────────────────────────

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: SisonkeColors.charcoal, size: 22),
                const Spacer(),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: SisonkeColors.charcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: SisonkeColors.charcoal.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
