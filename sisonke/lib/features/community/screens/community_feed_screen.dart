import 'package:flutter/material.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/shared/widgets/index.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    const groups = ['13-15', '16-17', '18-24', '25+'];
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: const SisonkeAppBar(title: 'Bamboo Forest'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ForestHeader(),
          const SizedBox(height: 16),
          const InfoPanel(
            icon: Icons.verified_user_rounded,
            title: 'Anonymous safe space',
            body:
                'Posts use age-group rooms, moderator approval, no direct messages, and report-first safety controls.',
          ),
          const SizedBox(height: 16),
          Text(
            'Age-group rooms',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: groups.map((group) {
              return ChoiceChip(
                label: Text(group),
                selected: _ageGroup == group,
                selectedColor: const Color(0xFFFFC857),
                onSelected: (_) {
                  setState(() => _ageGroup = group);
                  _loadPosts();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _post,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Whisper to the forest',
              helperText: 'Anonymous. Reviewed before it appears.',
              suffixIcon: IconButton(
                icon: const Icon(Icons.flag_outlined),
                tooltip: 'Report content',
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submitting ? null : _submitPost,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: const Text('Submit for review'),
          ),
          if (_notice != null) ...[
            const SizedBox(height: 12),
            Text(_notice!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Text(
            'Approved whispers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_posts.isEmpty)
            const InfoPanel(
              icon: Icons.hourglass_empty_rounded,
              title: 'Nothing public yet',
              body:
                  'Approved posts for this age group will appear here after moderation.',
            )
          else
            ..._posts.map(
              (post) => Card(
                color: const Color(0xFF1A2638),
                child: ListTile(
                  leading: const Icon(
                    Icons.local_florist_rounded,
                    color: Color(0xFF9BE7C4),
                  ),
                  title: Text(
                    '${post['content']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Anonymous - ${post['ageGroup'] ?? post['age_group'] ?? _ageGroup}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.flag_outlined,
                      color: Color(0xFFFFC857),
                    ),
                    tooltip: 'Report',
                    onPressed: () => setState(
                      () => _notice =
                          'Report flow is queued for moderator review.',
                    ),
                  ),
                ),
              ),
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
        _notice = 'Could not load the feed. Check that the backend is running.';
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
        _notice = '${response['message'] ?? 'Post submitted for moderation.'}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _notice =
            'Could not submit right now. Please try again when connected.';
      });
    }
  }
}

class _ForestHeader extends StatelessWidget {
  const _ForestHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2638),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF9BE7C4).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.nightlight_round, color: Color(0xFFFFC857)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bamboo Forest',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A calm campfire-style room for moderated anonymous support.',
                  style: TextStyle(color: Color(0xFFB7C4D8), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const InfoPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF22324A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF9BE7C4)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(color: Color(0xFFB7C4D8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
