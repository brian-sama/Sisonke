import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/core/services/api_service.dart';
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
    final topActionColor = colorScheme.primaryContainer.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SisonkeAppBar(
        title: 'Sisonke',
        showBackButton: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              color: colorScheme.primary,
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
                child: Icon(Icons.person_rounded, color: colorScheme.primary),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LivingDashboard(
                coral: coral,
                teal: teal,
                lemon: lemon,
                violet: violet,
              ),
              const SizedBox(height: 18),
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
                    label: 'Friend',
                    caption: 'Talk it through',
                    accentColor: violet,
                    backgroundColor: const Color(0xFFF0EDFF),
                    onTap: () => context.go('/e-friend'),
                  ),
                  _QuickActionCard(
                    icon: Icons.favorite_rounded,
                    label: 'Check-In',
                    caption: 'Mood + journal',
                    accentColor: coral,
                    backgroundColor: const Color(0xFFFFEEF0),
                    onTap: () => context.go('/check-in'),
                  ),
                  _QuickActionCard(
                    icon: Icons.groups_rounded,
                    label: 'Community',
                    caption: 'Safe Space',
                    accentColor: teal,
                    backgroundColor: const Color(0xFFE7FAFA),
                    onTap: () => context.go('/community'),
                  ),
                  _QuickActionCard(
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    caption: 'Counselor help',
                    accentColor: const Color(0xFFE7A500),
                    backgroundColor: const Color(0xFFFFF6D8),
                    onTap: () => context.go('/support'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Quick tools',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _WellnessLoopRow(
                items: [
                  _WellnessLoopItem(
                    Icons.self_improvement_rounded,
                    'Breathe',
                    '2 minutes',
                    const Color(0xFFE7FAFA),
                    () => context.push('/breathing'),
                  ),
                  _WellnessLoopItem(
                    Icons.edit_note_rounded,
                    'Gratitude Jar',
                    'Add one good thing',
                    const Color(0xFFFFF6D8),
                    () => context.push('/journal-entry?mode=gratitude'),
                  ),
                  _WellnessLoopItem(
                    Icons.flag_rounded,
                    'Safety plan',
                    'Plan ahead',
                    const Color(0xFFFFEEF0),
                    () => context.push('/safety-plan'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _MoreSupportCard(teal: teal, coral: coral, violet: violet),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learn & Grow',
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
              _FeaturedResourceFromApi(accentColor: lemon),
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

class _LivingDashboard extends StatelessWidget {
  final Color coral;
  final Color teal;
  final Color lemon;
  final Color violet;

  const _LivingDashboard({
    required this.coral,
    required this.teal,
    required this.lemon,
    required this.violet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.water_drop_rounded, color: teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Home Garden',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Chip(
                avatar: Icon(Icons.spa_rounded, size: 16, color: teal),
                label: const Text('Calm'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'One calm place for check-ins, support, and private tools.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatusPill(
                color: lemon,
                icon: Icons.inbox_rounded,
                value: '1 gratitude',
                onTap: () => context.push('/journal-entry?mode=gratitude'),
              ),
              const SizedBox(width: 10),
              _StatusPill(
                color: coral,
                icon: Icons.mood_rounded,
                value: 'Mood open',
                onTap: () => context.go('/check-in/mood'),
              ),
              const SizedBox(width: 10),
              _StatusPill(
                color: violet,
                icon: Icons.support_agent_rounded,
                value: 'Support ready',
                onTap: () => context.go('/support'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _StatusPill({
    required this.color,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
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

class _WellnessLoopItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _WellnessLoopItem(
    this.icon,
    this.title,
    this.subtitle,
    this.color,
    this.onTap,
  );
}

class _WellnessLoopRow extends StatelessWidget {
  final List<_WellnessLoopItem> items;

  const _WellnessLoopRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 170,
            child: Material(
              color: item.color,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: const Color(0xFF14213D)),
                      const Spacer(),
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(
                            0xFF14213D,
                          ).withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoreSupportCard extends StatelessWidget {
  final Color teal;
  final Color coral;
  final Color violet;

  const _MoreSupportCard({
    required this.teal,
    required this.coral,
    required this.violet,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        leading: Icon(Icons.more_horiz_rounded, color: teal),
        title: const Text(
          'More options',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: const Text('Learn, Q&A, bookmarks, safety settings'),
        children: [
          _CompactNavTile(
            icon: Icons.menu_book_rounded,
            color: teal,
            label: 'Learn & Grow',
            route: '/resources',
          ),
          _CompactNavTile(
            icon: Icons.forum_rounded,
            color: violet,
            label: 'Anonymous Q&A',
            route: '/qa',
          ),
          _CompactNavTile(
            icon: Icons.bookmark_rounded,
            color: coral,
            label: 'Bookmarks',
            route: '/bookmarks',
          ),
          _CompactNavTile(
            icon: Icons.admin_panel_settings_rounded,
            color: colorScheme.primary,
            label: 'Profile & Safety',
            route: '/profile-safety',
          ),
        ],
      ),
    );
  }
}

class _CompactNavTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String route;

  const _CompactNavTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(route),
    );
  }
}

class _FeaturedResourceFromApi extends StatefulWidget {
  final Color accentColor;

  const _FeaturedResourceFromApi({required this.accentColor});

  @override
  State<_FeaturedResourceFromApi> createState() =>
      _FeaturedResourceFromApiState();
}

class _FeaturedResourceFromApiState extends State<_FeaturedResourceFromApi> {
  late final Future<Map<String, dynamic>?> _future = _loadResource();

  Future<Map<String, dynamic>?> _loadResource() async {
    final response = await ApiService().getResources(
      category: 'wellness',
      limit: 1,
    );
    final resources = response['resources'];
    if (resources is List && resources.isNotEmpty) {
      return Map<String, dynamic>.from(resources.first as Map);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _future,
      builder: (context, snapshot) {
        final item = snapshot.data;
        final id = item?['id'];
        return _FeaturedResourceCard(
          accentColor: widget.accentColor,
          title: '${item?['title'] ?? 'Understanding your emotions'}',
          category: '${item?['category'] ?? 'Feelings 101'}',
          description:
              '${item?['description'] ?? 'A quick guide to naming what you feel and choosing your next gentle step.'}',
          minutes:
              '${item?['readingTimeMinutes'] ?? item?['reading_time_minutes'] ?? 3} min',
          loading: snapshot.connectionState == ConnectionState.waiting,
          onRead: () {
            if (id is String && id.isNotEmpty) {
              context.push('/resources/$id');
              return;
            }
            context.push('/resources');
          },
        );
      },
    );
  }
}

class _FeaturedResourceCard extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String category;
  final String description;
  final String minutes;
  final bool loading;
  final VoidCallback onRead;

  const _FeaturedResourceCard({
    required this.accentColor,
    required this.title,
    required this.category,
    required this.description,
    required this.minutes,
    required this.loading,
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
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
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
                      loading ? 'Loading' : category,
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
                    tooltip: 'Open bookmarks',
                    color: colorScheme.onSurface,
                    onPressed: () => context.push('/bookmarks'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
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
                    minutes,
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
            border: Border.all(
              color: colorScheme.surface.withValues(alpha: 0.9),
            ),
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
                  color: const Color(
                    0xFF14213D,
                  ), // Force dark text on light action cards
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
                  color: const Color(0xFF14213D).withValues(
                    alpha: 0.65,
                  ), // Force dark caption on light action cards
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
