import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SisonkeScaffold(
      title: 'Check-In',
      fallbackBackLocation: '/home',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          const WellnessIllustrationCard(
            title: 'Mind workouts',
            body:
                'Small tools for tracking, reflecting, breathing, and feeling supported.',
            icon: Icons.spa_rounded,
            color: SisonkeColors.mint,
          ),
          const SizedBox(height: 22),
          const SoftSectionHeader(
            title: 'What would help right now?',
            subtitle: 'Choose one gentle action. You can always come back.',
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.98,
            children: [
              PastelToolCard(
                title: 'Mood Tracker',
                subtitle: 'Name the feeling',
                icon: Icons.mood_rounded,
                color: SisonkeColors.sky,
                onTap: () => context.push('/check-in/mood'),
              ),
              PastelToolCard(
                title: 'Journal',
                subtitle: 'Free, gratitude, worry',
                icon: Icons.edit_note_rounded,
                color: SisonkeColors.lemon,
                onTap: () => context.push('/check-in/journal'),
              ),
              PastelToolCard(
                title: '1 min Breathing',
                subtitle: 'Slow the moment',
                icon: Icons.self_improvement_rounded,
                color: SisonkeColors.sage,
                onTap: () => context.push('/breathing'),
              ),
              PastelToolCard(
                title: 'Grounding',
                subtitle: 'Come back to now',
                icon: Icons.landscape_rounded,
                color: SisonkeColors.blush,
                onTap: () => context.push('/grounding'),
              ),
              PastelToolCard(
                title: 'Goal Tracker',
                subtitle: 'One small step',
                icon: Icons.flag_rounded,
                color: SisonkeColors.lavender,
                onTap: () => context.push('/check-in/recovery'),
              ),
              PastelToolCard(
                title: 'Sisonke Friend',
                subtitle: 'Talk it through',
                icon: Icons.smart_toy_rounded,
                color: SisonkeColors.clay,
                onTap: () => context.go('/e-friend'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          RoundedPrimaryButton(
            label: 'Talk to someone',
            icon: Icons.support_agent_rounded,
            onPressed: () => context.push('/talk-to-counselor'),
          ),
        ],
      ),
    );
  }
}
