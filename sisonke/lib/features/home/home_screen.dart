import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/widgets/index.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const coral = Color(0xFFFF5A5F);
    const teal = Color(0xFF00A6A6);
    const lemon = Color(0xFFFFC857);
    const violet = Color(0xFF7B61FF);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SisonkeAppBar(
        title: 'Sisonke',
        showBackButton: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: 'Notifications',
              onPressed: () => context.push('/notifications'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              tooltip: 'Profile menu',
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
                child: Icon(Icons.person_rounded, color: colorScheme.primary),
              ),
              onSelected: (value) => context.push(value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: '/profile-safety', child: Text('Profile & Safety')),
                PopupMenuItem(value: '/settings', child: Text('Settings')),
                PopupMenuItem(value: '/resources', child: Text('Resources / Learn')),
                PopupMenuItem(value: '/emergency', child: Text('Emergency Support')),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A6A6), Color(0xFF7B61FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: violet.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'You are not alone',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your private support space',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Check in, breathe, ask, or build a plan at your own pace.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Start here',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.12,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _QuickActionCard(
                    icon: Icons.smart_toy_rounded,
                    label: 'E-Friend',
                    caption: 'Chat with safety routing',
                    accentColor: violet,
                    backgroundColor: const Color(0xFFF0EDFF),
                    onTap: () => context.go('/e-friend'),
                  ),
                  _QuickActionCard(
                    icon: Icons.favorite_rounded,
                    label: 'Check-In',
                    caption: 'Mood, journal, recovery',
                    accentColor: coral,
                    backgroundColor: const Color(0xFFFFEEF0),
                    onTap: () => context.go('/check-in'),
                  ),
                  _QuickActionCard(
                    icon: Icons.groups_rounded,
                    label: 'Community',
                    caption: 'Age-gated moderated feed',
                    accentColor: teal,
                    backgroundColor: const Color(0xFFE7FAFA),
                    onTap: () => context.go('/community'),
                  ),
                  _QuickActionCard(
                    icon: Icons.support_agent_rounded,
                    label: 'Counselor',
                    caption: 'Request human support',
                    accentColor: const Color(0xFFE7A500),
                    backgroundColor: const Color(0xFFFFF6D8),
                    onTap: () => context.push('/talk-to-counselor'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Main sections',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _SectionList(
                sections: [
                  _SectionItem(Icons.home_rounded, 'Home', '/home'),
                  _SectionItem(Icons.mood_rounded, 'Mood Tracker', '/mood-tracker'),
                  _SectionItem(Icons.edit_note_rounded, 'Private Journal', '/private-journal'),
                  _SectionItem(Icons.smart_toy_rounded, 'E-Friend Chatbot', '/e-friend'),
                  _SectionItem(Icons.support_agent_rounded, 'Talk to a Counselor', '/talk-to-counselor'),
                  _SectionItem(Icons.groups_rounded, 'Community Feed', '/community'),
                  _SectionItem(Icons.menu_book_rounded, 'Resources / Learn', '/resources'),
                  _SectionItem(Icons.forum_rounded, 'Anonymous Q&A', '/qa'),
                  _SectionItem(Icons.shield_rounded, 'Emergency Toolkit', '/emergency'),
                  _SectionItem(Icons.admin_panel_settings_rounded, 'Profile & Safety Settings', '/profile-safety'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured resources',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/resources'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FeaturedResourceCard(
                accentColor: lemon,
                onRead: () => context.push('/resources'),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEF0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.lock_rounded, color: coral),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Private by design. Use Quick Exit any time you need privacy.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: EmergencyHelpButton(
        onPressed: () => context.push('/emergency'),
      ),
    );
  }
}

class _SectionItem {
  final IconData icon;
  final String label;
  final String route;

  const _SectionItem(this.icon, this.label, this.route);
}

class _SectionList extends StatelessWidget {
  final List<_SectionItem> sections;

  const _SectionList({required this.sections});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: sections.map((section) {
          return ListTile(
            leading: Icon(section.icon),
            title: Text(section.label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(section.route),
          );
        }).toList(),
      ),
    );
  }
}

class _FeaturedResourceCard extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onRead;

  const _FeaturedResourceCard({
    required this.accentColor,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onRead,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Feelings 101',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded),
                    tooltip: 'Save',
                    color: colorScheme.onSurface,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to bookmarks')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Understanding your emotions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A quick guide to naming what you feel and choosing your next gentle step.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: onRead,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Read'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.onSurface,
                      foregroundColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '3 min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String caption;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.caption,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.surface.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 24, color: accentColor),
              ),
              const Spacer(),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.58),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
