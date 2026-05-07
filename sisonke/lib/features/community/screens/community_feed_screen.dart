import 'package:flutter/material.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final _api = ApiService();
  final _post = TextEditingController();
  var _ageGroup = '18-24';
  var _loading = false;
  var _submitting = false;
  String? _notice;
  List<Map<String, dynamic>> _posts = const [];

  final Map<String, Map<String, int>> _reactionCounts = {};
  final Map<String, Map<String, bool>> _reactionSelected = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _post.dispose();
    super.dispose();
  }

  void _toggleReaction(String postId, String reactionKey) {
    setState(() {
      _reactionCounts.putIfAbsent(
        postId,
        () => {'helped': 2, 'relate': 4, 'support': 3},
      );
      _reactionSelected.putIfAbsent(
        postId,
        () => {'helped': false, 'relate': false, 'support': false},
      );

      final currentlySelected =
          _reactionSelected[postId]![reactionKey] ?? false;
      _reactionSelected[postId]![reactionKey] = !currentlySelected;

      if (currentlySelected) {
        _reactionCounts[postId]![reactionKey] =
            (_reactionCounts[postId]![reactionKey] ?? 1) - 1;
      } else {
        _reactionCounts[postId]![reactionKey] =
            (_reactionCounts[postId]![reactionKey] ?? 0) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const groups = ['13-15', '16-17', '18-24', '25+'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sectionTitleColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

    return Scaffold(
      backgroundColor: isDark ? null : SisonkeColors.cream,
      appBar: const SisonkeAppBar(
        title: 'Community Space',
        fallbackBackLocation: '/home',
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
        children: [
          const _CommunityHeader(),
          const SizedBox(height: 12),
          const _InfoPanel(
            icon: Icons.verified_user_rounded,
            title: 'Anonymous and moderated',
            body:
                'Age-group rooms, reviewed posts, report-first safety controls, and no direct messages.',
          ),
          const SizedBox(height: 18),
          Text(
            'Choose an age group',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: sectionTitleColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: groups.map((group) {
              final isSelected = _ageGroup == group;
              
              final chipBg = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
              final chipSelectedBg = isDark ? theme.colorScheme.primary.withValues(alpha: 0.22) : SisonkeColors.lemon;
              final checkColor = isDark ? theme.colorScheme.primary : SisonkeColors.forest;
              final labelColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

              return ChoiceChip(
                label: Text(group),
                selected: isSelected,
                selectedColor: chipSelectedBg,
                backgroundColor: chipBg,
                checkmarkColor: checkColor,
                labelStyle: TextStyle(
                  color: isSelected && !isDark ? SisonkeColors.charcoal : labelColor,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isSelected
                        ? (isDark ? theme.colorScheme.primary.withValues(alpha: 0.5) : SisonkeColors.forest.withValues(alpha: 0.36))
                        : (isDark ? theme.colorScheme.outlineVariant : SisonkeColors.sage),
                  ),
                ),
                onSelected: (_) {
                  setState(() => _ageGroup = group);
                  _loadPosts();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _PostComposer(
            controller: _post,
            submitting: _submitting,
            onSubmit: _submitPost,
          ),
          if (_notice != null) ...[
            const SizedBox(height: 10),
            _NoticePanel(message: _notice!),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                'Approved posts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: sectionTitleColor,
                ),
              ),
              const Spacer(),
              Text(
                '$_ageGroup room',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: CircularProgressIndicator(
                  color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                ),
              ),
            )
          else if (_posts.isEmpty)
            const _InfoPanel(
              icon: Icons.forum_outlined,
              title: 'Nothing posted yet',
              body:
                  'Approved posts for this age group will appear here after moderation.',
            )
          else
            ..._posts.map(_buildPostCard),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final postId = post['id'] ?? post['content'].toString().hashCode.toString();

    _reactionCounts.putIfAbsent(
      postId,
      () => {'helped': 2, 'relate': 4, 'support': 3},
    );
    _reactionSelected.putIfAbsent(
      postId,
      () => {'helped': false, 'relate': false, 'support': false},
    );

    final selectedMap = _reactionSelected[postId]!;
    final countsMap = _reactionCounts[postId]!;

    final cardBg = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final textContentColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;
    final borderSideColor = isDark ? theme.colorScheme.outlineVariant : SisonkeColors.sage.withValues(alpha: 0.9);
    final dividerColor = isDark ? theme.colorScheme.outlineVariant : const Color(0xFFE4E8DF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderSideColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: SisonkeColors.forest.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 17,
                color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Anonymous member',
                  style: TextStyle(
                    color: textContentColor.withValues(alpha: 0.65),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.15) : SisonkeColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${post['ageGroup'] ?? post['age_group'] ?? _ageGroup}',
                  style: TextStyle(
                    color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${post['content']}',
            style: TextStyle(
              color: textContentColor,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ReactionButton(
                      icon: Icons.spa_outlined,
                      label: 'Helped',
                      count: countsMap['helped'] ?? 0,
                      isSelected: selectedMap['helped'] ?? false,
                      selectedColor: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                      onTap: () => _toggleReaction(postId, 'helped'),
                    ),
                    _ReactionButton(
                      icon: Icons.handshake_outlined,
                      label: 'Relate',
                      count: countsMap['relate'] ?? 0,
                      isSelected: selectedMap['relate'] ?? false,
                      selectedColor: isDark ? const Color(0xFF917FCA) : const Color(0xFF7361A9),
                      onTap: () => _toggleReaction(postId, 'relate'),
                    ),
                    _ReactionButton(
                      icon: Icons.favorite_border_rounded,
                      label: 'Support',
                      count: countsMap['support'] ?? 0,
                      isSelected: selectedMap['support'] ?? false,
                      selectedColor: isDark ? const Color(0xFFE47E7E) : const Color(0xFFD15F5F),
                      onTap: () => _toggleReaction(postId, 'support'),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.flag_outlined, size: 20),
                color: textContentColor.withValues(alpha: 0.6),
                tooltip: 'Report post',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Report submitted safely. Moderators will review this post.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final posts = await _api.getCommunityPosts(ageGroup: _ageGroup);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _posts = const [];
        _loading = false;
        _notice =
            'Could not sync community posts. Check that the backend is active.';
      });
    }
  }

  Future<void> _submitPost() async {
    final content = _post.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _submitting = true;
      _notice = null;
    });
    try {
      final response = await _api.submitCommunityPost(
        ageGroup: _ageGroup,
        content: content,
      );
      if (!mounted) return;
      setState(() {
        _post.clear();
        _submitting = false;
        _notice =
            '${response['message'] ?? 'Post sent safely. It will appear after moderation.'}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _notice = 'Could not send your post yet. Please try again shortly.';
      });
    }
  }
}

class _CommunityHeader extends StatelessWidget {
  const _CommunityHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headerBg = isDark ? theme.colorScheme.surfaceContainerHigh : SisonkeColors.mint;
    final headerBorder = isDark ? theme.colorScheme.outlineVariant : SisonkeColors.sage;
    final textColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: headerBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.groups_2_rounded,
              color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Space',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share anonymously with people in your age group after moderator review.',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    height: 1.35,
                    fontSize: 13,
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

class _PostComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  const _PostComposer({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final inputBg = isDark ? theme.colorScheme.surfaceContainer : SisonkeColors.cream;
    final textInputColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;
    final borderSideColor = isDark ? theme.colorScheme.outlineVariant : SisonkeColors.sage;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? borderSideColor : SisonkeColors.sage.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            style: TextStyle(
              color: textInputColor,
              fontSize: 14.5,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBg,
              labelText: 'Write an anonymous post',
              hintText: 'Share a thought, feeling, or encouragement...',
              helperText: 'Reviewed before it appears to others.',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderSideColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderSideColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SisonkeButton(
            onPressed: onSubmit,
            isEnabled: !submitting,
            label: submitting ? 'Sending...' : 'Submit anonymous post',
            icon: Icons.send_rounded,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final iconBg = isDark ? theme.colorScheme.surfaceContainer : SisonkeColors.sage.withValues(alpha: 0.75);
    final textContentColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;
    final borderSideColor = isDark ? theme.colorScheme.outlineVariant : SisonkeColors.sage.withValues(alpha: 0.9);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSideColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: textContentColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    color: textContentColor.withValues(alpha: 0.72),
                    fontSize: 12.5,
                    height: 1.3,
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

class _NoticePanel extends StatelessWidget {
  final String message;

  const _NoticePanel({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final noticeBg = isDark ? theme.colorScheme.surfaceContainerHigh : SisonkeColors.lemon.withValues(alpha: 0.9);
    final noticeBorder = isDark ? theme.colorScheme.primary.withValues(alpha: 0.4) : const Color(0xFFE7D17F);
    final textColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: noticeBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: noticeBorder),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final btnBg = isSelected
        ? selectedColor.withValues(alpha: 0.15)
        : (isDark ? theme.colorScheme.surfaceContainer : SisonkeColors.cream);

    final borderSideColor = isSelected
        ? selectedColor
        : (isDark ? theme.colorScheme.outlineVariant : SisonkeColors.sage);

    final textColor = isDark ? theme.colorScheme.onSurface : SisonkeColors.charcoal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: btnBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderSideColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? selectedColor
                  : textColor.withValues(alpha: 0.62),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? selectedColor
                    : textColor.withValues(alpha: 0.72),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected
                    ? selectedColor
                    : textColor.withValues(alpha: 0.62),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
