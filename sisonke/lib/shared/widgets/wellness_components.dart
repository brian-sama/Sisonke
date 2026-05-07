import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/sisonke_app_bar.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class SisonkeScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final String? fallbackBackLocation;

  const SisonkeScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.fallbackBackLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? null : SisonkeColors.cream,
      appBar: SisonkeAppBar(
        title: title,
        actions: actions,
        fallbackBackLocation: fallbackBackLocation,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class SoftSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SoftSectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withValues(alpha: 0.72),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class PastelToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const PastelToolCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? theme.colorScheme.surfaceContainerHigh : color;
    final textColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(28),
      shape: isDark
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              ),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Semantics(
          button: true,
          label: '$title. $subtitle',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NatureBadge(icon: icon, isDarkContext: isDark),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w700,
                    height: 1.15,
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

class WellnessIllustrationCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color color;

  const WellnessIllustrationCard({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? theme.colorScheme.surfaceContainerHigh : color;
    final textColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: isDark
            ? Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          _NatureBadge(icon: icon, size: 58, isDarkContext: isDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
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

class RoundedPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const RoundedPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _NatureBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isDarkContext;

  const _NatureBadge({
    required this.icon,
    this.size = 52,
    this.isDarkContext = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDarkContext
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Icon(
        icon,
        color: isDarkContext ? theme.colorScheme.primary : SisonkeColors.forest,
      ),
    );
  }
}
