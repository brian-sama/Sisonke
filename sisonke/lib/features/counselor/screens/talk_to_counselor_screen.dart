import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

class TalkToCounselorScreen extends StatelessWidget {
  const TalkToCounselorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Talk to Someone'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: SisonkeColors.forestBreeze,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          children: [
            const SizedBox(height: 8),
            Text(
              'Choose the safest way to reach a supportive counselor.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2F3433),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sisonke is a completely secure, private, and non-judgmental space.',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2F3433).withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 20),
            
            _SupportOption(
              icon: Icons.support_agent_rounded,
              title: 'Start counselor request',
              body: 'Choose a category, share what’s on your mind, and create a private case.',
              color: const Color(0xFF2E6F60), // Calm Sage-Teal
              onTap: () => context.push('/counselor-request?method=live_chat'),
            ),
            _SupportOption(
              icon: Icons.call_rounded,
              title: 'Request callback',
              body: 'Have a counselor call you securely at a safe telephone number.',
              color: const Color(0xFFFFC857), // Amber Warmth
              onTap: () => context.push('/counselor-request?method=callback'),
            ),
            _SupportOption(
              icon: Icons.mic_rounded,
              title: 'Send voice note',
              body: 'If writing feels too heavy, leave a secure audio recording instead.',
              color: const Color(0xFF7361A9), // Royal Lavender
              onTap: () => context.push('/counselor-request?method=voice_note'),
            ),
            _SupportOption(
              icon: Icons.history_rounded,
              title: 'Case history',
              body: 'Check previous requests, statuses, and safe follow-ups.',
              color: const Color(0xFFD68A7F), // Blush Rose
              onTap: () => context.push('/case-history'),
            ),
            _SupportOption(
              icon: Icons.health_and_safety_rounded,
              title: 'Emergency escalation',
              body: 'Safety cannot wait. Access urgent local helplines instantly.',
              color: const Color(0xFFE07A5F), // Coral Earth
              onTap: () => context.push('/emergency'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final VoidCallback onTap;

  const _SupportOption({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                // Curved Icon Backdrop
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2F3433),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF2F3433).withOpacity(0.6),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: const Color(0xFF2F3433).withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
