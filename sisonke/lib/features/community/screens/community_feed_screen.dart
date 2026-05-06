import 'dart:math' as math;
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

  // Local state to manage reaction counters and selection anonymously
  final Map<String, Map<String, int>> _reactionCounts = {};
  final Map<String, Map<String, bool>> _reactionSelected = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _toggleReaction(String postId, String reactionKey) {
    setState(() {
      _reactionCounts.putIfAbsent(postId, () => {'helped': 2, 'relate': 4, 'support': 3});
      _reactionSelected.putIfAbsent(postId, () => {'helped': false, 'relate': false, 'support': false});

      final currentlySelected = _reactionSelected[postId]![reactionKey] ?? false;
      _reactionSelected[postId]![reactionKey] = !currentlySelected;

      if (currentlySelected) {
        _reactionCounts[postId]![reactionKey] = (_reactionCounts[postId]![reactionKey] ?? 1) - 1;
      } else {
        _reactionCounts[postId]![reactionKey] = (_reactionCounts[postId]![reactionKey] ?? 0) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const groups = ['13-15', '16-17', '18-24', '25+'];
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Bamboo Forest'),
      body: Stack(
        children: [
          // 1. Deep indigo night sky background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)], // Slate-900 to Indigo-950
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // 2. Animated floating campfire embers overlay
          const Positioned.fill(
            child: _CampfireEmberStack(),
          ),

          // 3. Main scrollable community feed content
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const _ForestHeader(),
              const SizedBox(height: 16),
              const InfoPanel(
                icon: Icons.verified_user_rounded,
                title: 'Anonymous safe space',
                body: 'Posts use age-group rooms, moderator approval, no direct messages, and report-first safety controls.',
              ),
              const SizedBox(height: 20),
              
              // Age group selector header
              Text(
                'Select your age-group room:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: groups.map((group) {
                  final isSelected = _ageGroup == group;
                  return ChoiceChip(
                    label: Text(
                      group,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFC857), // Golden warmth
                    backgroundColor: Colors.white.withOpacity(0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (_) {
                      setState(() => _ageGroup = group);
                      _loadPosts();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Whisper submission container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _post,
                      minLines: 3,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white, fontSize: 14.5),
                      decoration: InputDecoration(
                        fillColor: Colors.white.withOpacity(0.04),
                        labelText: 'Whisper to the forest',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        hintText: 'Share an anonymous thought or feeling...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        helperText: 'Anonymous. Reviewed before it appears to others.',
                        helperStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SisonkeButton(
                      onPressed: () => _submitPost(),
                      isEnabled: !_submitting,
                      label: _submitting ? 'Sending Whisper...' : 'Submit anonymous post',
                      icon: Icons.send_rounded,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
              if (_notice != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6F60).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E6F60).withOpacity(0.4)),
                  ),
                  child: Text(
                    _notice!,
                    style: const TextStyle(color: Color(0xFF9BE7C4), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              Text(
                'Approved whispers',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 10),

              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFFFFC857)),
                  ),
                )
              else if (_posts.isEmpty)
                const InfoPanel(
                  icon: Icons.hourglass_empty_rounded,
                  title: 'Silence in the forest',
                  body: 'Approved posts for this room will appear here near the campfire once moderated.',
                )
              else
                ..._posts.map((post) {
                  final postId = post['id'] ?? post['content'].toString().hashCode.toString();
                  
                  _reactionCounts.putIfAbsent(postId, () => {'helped': 2, 'relate': 4, 'support': 3});
                  _reactionSelected.putIfAbsent(postId, () => {'helped': false, 'relate': false, 'support': false});

                  final selectedMap = _reactionSelected[postId]!;
                  final countsMap = _reactionCounts[postId]!;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.eco_outlined, size: 16, color: Color(0xFF9BE7C4)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Anonymous Traveler',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${post['ageGroup'] ?? post['age_group'] ?? _ageGroup} Room',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${post['content']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.45,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 12),
                          
                          // Custom anonymous reaction rows
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _ReactionButton(
                                      emoji: '🌱',
                                      label: 'This helped',
                                      count: countsMap['helped'] ?? 0,
                                      isSelected: selectedMap['helped'] ?? false,
                                      selectedColor: const Color(0xFF2E6F60),
                                      onTap: () => _toggleReaction(postId, 'helped'),
                                    ),
                                    _ReactionButton(
                                      emoji: '🤝',
                                      label: 'I relate',
                                      count: countsMap['relate'] ?? 0,
                                      isSelected: selectedMap['relate'] ?? false,
                                      selectedColor: const Color(0xFF7361A9),
                                      onTap: () => _toggleReaction(postId, 'relate'),
                                    ),
                                    _ReactionButton(
                                      emoji: '🕊️',
                                      label: 'Support',
                                      count: countsMap['support'] ?? 0,
                                      isSelected: selectedMap['support'] ?? false,
                                      selectedColor: const Color(0xFFD68A7F),
                                      onTap: () => _toggleReaction(postId, 'support'),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.flag_outlined, size: 20),
                                color: const Color(0xFFFFC857).withOpacity(0.7),
                                tooltip: 'Report Post',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Color(0xFFD68A7F),
                                      content: Text('Report submitted safely. Moderators will review this post.'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 48),
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
        _notice = 'Could not sync the forest. Check that the backend is active.';
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
        _notice = '${response['message'] ?? 'Whisper sent safely. Under mod review.'}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _notice = 'Sync failure. Let’s try sending your whisper again shortly.';
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC857).withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.fireplace_rounded, color: Color(0xFFFFC857), size: 30),
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
                  'Sit around our digital campfire. Share whispers anonymously with others in your age group.',
                  style: TextStyle(color: Color(0xFFB7C4D8), height: 1.35, fontSize: 13),
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
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF9BE7C4)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.5, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stateful interactive, brand-matched anonymous reaction button
class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? selectedColor.withOpacity(0.24) 
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Campfire Embers slow floating particle physics stack
class _CampfireEmberStack extends StatefulWidget {
  const _CampfireEmberStack();

  @override
  State<_CampfireEmberStack> createState() => _CampfireEmberStackState();
}

class _CampfireEmberStackState extends State<_CampfireEmberStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_EmberParticle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Spawn 15 slow orange fire ember particles
    for (int i = 0; i < 15; i++) {
      _particles.add(_EmberParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2.0 + _random.nextDouble() * 3.5,
        speed: 0.0015 + _random.nextDouble() * 0.002,
        swaySpeed: 1.0 + _random.nextDouble() * 2.0,
        swayWidth: 0.015 + _random.nextDouble() * 0.02,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (final p in _particles) {
          p.y -= p.speed; // ascend
          if (p.y < -0.1) {
            p.y = 1.1; // reset bottom loop
            p.x = _random.nextDouble();
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            if (w == 0 || h == 0) return const SizedBox.shrink();

            return Stack(
              children: _particles.map((p) {
                final sway = math.sin(_controller.value * math.pi * 2 * p.swaySpeed) * p.swayWidth;
                final dx = ((p.x + sway) % 1.0) * w;
                final dy = p.y * h;

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF07167).withOpacity(0.6), // Fire warm red
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC857).withOpacity(0.55), // warm golden ember halo
                          blurRadius: p.size * 1.5,
                          spreadRadius: p.size * 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class _EmberParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double swaySpeed;
  final double swayWidth;

  _EmberParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.swaySpeed,
    required this.swayWidth,
  });
}
