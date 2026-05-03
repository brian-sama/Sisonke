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
      appBar: const SisonkeAppBar(title: 'Community Feed'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoPanel(
            icon: Icons.verified_user_rounded,
            title: 'Public moderated feed only',
            body: 'Posts are age-gated, reviewed before appearing, and random private messaging is disabled for the first version.',
          ),
          const SizedBox(height: 16),
          Text('Age groups', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: groups.map((group) {
              return ChoiceChip(
                label: Text(group),
                selected: _ageGroup == group,
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
              labelText: 'Share a moderated post',
              suffixIcon: IconButton(icon: const Icon(Icons.flag_outlined), tooltip: 'Report content', onPressed: () {}),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submitting ? null : _submitPost,
            icon: _submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_rounded),
            label: const Text('Submit for review'),
          ),
          if (_notice != null) ...[
            const SizedBox(height: 12),
            Text(_notice!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Text('Approved posts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_posts.isEmpty)
            const InfoPanel(
              icon: Icons.hourglass_empty_rounded,
              title: 'Nothing public yet',
              body: 'Approved posts for this age group will appear here after moderation.',
            )
          else
            ..._posts.map((post) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.groups_rounded),
                    title: Text('${post['content']}'),
                    subtitle: Text('Age group: ${post['ageGroup'] ?? post['age_group'] ?? _ageGroup}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.flag_outlined),
                      tooltip: 'Report',
                      onPressed: () => setState(() => _notice = 'Report flow is queued for moderator review.'),
                    ),
                  ),
                )),
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
      final response = await _api.submitCommunityPost(ageGroup: _ageGroup, content: content);
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
        _notice = 'Could not submit right now. Please try again when connected.';
      });
    }
  }
}

class InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const InfoPanel({super.key, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
