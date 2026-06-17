import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  static const _circles = [
    _CircleTheme(
      id: 'grief-loss',
      label: 'Grief & Loss',
      icon: Icons.favorite_border_rounded,
      color: SisonkeColors.blush,
    ),
    _CircleTheme(
      id: 'exam-stress',
      label: 'Exam Stress',
      icon: Icons.school_outlined,
      color: SisonkeColors.lemon,
    ),
    _CircleTheme(
      id: 'anxiety',
      label: 'Anxiety',
      icon: Icons.air_rounded,
      color: SisonkeColors.sky,
    ),
    _CircleTheme(
      id: 'loneliness',
      label: 'Loneliness',
      icon: Icons.person_outline_rounded,
      color: SisonkeColors.lavender,
    ),
    _CircleTheme(
      id: 'anger',
      label: 'Anger',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFFFEEF0),
    ),
    _CircleTheme(
      id: 'sobriety-journey',
      label: 'Sobriety Journey',
      icon: Icons.self_improvement_rounded,
      color: SisonkeColors.mint,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Ubuntu Circles'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: SisonkeColors.secondaryDim,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: SisonkeColors.secondary.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SisonkeColors.lavender,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: SisonkeColors.secondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anonymous healing spaces',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'for shared journeys',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SisonkeColors.secondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choose a circle',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          // ── Grid of circle cards ────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: _circles.map((circle) {
              return _CircleCard(
                circle: circle,
                onTap: () => context.push(
                  '/circles/${circle.id}?theme=${Uri.encodeComponent(circle.label)}',
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // ── Disclaimer ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SisonkeColors.primaryDim,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: SisonkeColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All messages are anonymous. Groups have a maximum of 8 members.',
                    style: TextStyle(
                      fontSize: 12,
                      color: SisonkeColors.primary.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
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
}

// ─── Data model ───────────────────────────────────────────────────────────────
class _CircleTheme {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const _CircleTheme({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

// ─── Card widget ──────────────────────────────────────────────────────────────
class _CircleCard extends StatelessWidget {
  final _CircleTheme circle;
  final VoidCallback onTap;

  const _CircleCard({required this.circle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: circle.color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(circle.icon, size: 22, color: const Color(0xFF14213D)),
              ),
              const Spacer(),
              Text(
                circle.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF14213D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anonymous group',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF14213D).withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
