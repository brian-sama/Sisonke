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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Ubuntu Circles'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF261D33) : SisonkeColors.secondaryDim,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF4B3463)
                    : SisonkeColors.secondary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3E2856) : SisonkeColors.lavender,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: isDark ? const Color(0xFFC4B5FD) : SisonkeColors.secondary,
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
                          color: isDark ? Colors.white : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'for shared journeys',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFFC4B5FD)
                              : SisonkeColors.secondary.withValues(alpha: 0.8),
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
              color: isDark ? const Color(0xFF2A1523) : SisonkeColors.primaryDim,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(color: SisonkeColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: isDark ? const Color(0xFFEE2B5E) : SisonkeColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All messages are anonymous. Groups have a maximum of 8 members.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFFAD1E6)
                          : SisonkeColors.primary.withValues(alpha: 0.85),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? theme.colorScheme.surfaceContainerHigh : circle.color;
    final cardBorder = isDark
        ? Border.all(color: circle.color.withValues(alpha: 0.35), width: 1.2)
        : null;
    final iconBg = isDark
        ? circle.color.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.65);
    final iconColor = isDark
        ? (Color.lerp(circle.color, Colors.white, 0.45) ?? circle.color)
        : const Color(0xFF14213D);
    final textColor = isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D);
    final subtitleColor = isDark
        ? theme.colorScheme.onSurfaceVariant
        : const Color(0xFF14213D).withValues(alpha: 0.55);

    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: cardBorder?.top ?? BorderSide.none,
      ),
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
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(circle.icon, size: 22, color: iconColor),
              ),
              const Spacer(),
              Text(
                circle.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anonymous group',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
