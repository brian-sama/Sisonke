import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

class VisualPost {
  final String id;
  final String mediaType; // 'image' or 'video'
  final String mediaPath;
  final int fileSizeBytes;
  final String moodAura;
  final String authorAlias;
  final DateTime timestamp;
  Map<String, int> reactions;
  Set<String> userReactions;

  VisualPost({
    required this.id,
    required this.mediaType,
    required this.mediaPath,
    required this.fileSizeBytes,
    required this.moodAura,
    required this.authorAlias,
    required this.timestamp,
    required this.reactions,
    required this.userReactions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mediaType': mediaType,
        'mediaPath': mediaPath,
        'fileSizeBytes': fileSizeBytes,
        'moodAura': moodAura,
        'authorAlias': authorAlias,
        'timestamp': timestamp.toIso8601String(),
        'reactions': reactions,
        'userReactions': userReactions.toList(),
      };

  factory VisualPost.fromJson(Map<String, dynamic> json) => VisualPost(
        id: json['id'] as String,
        mediaType: json['mediaType'] as String? ?? 'image',
        mediaPath: json['mediaPath'] as String,
        fileSizeBytes: json['fileSizeBytes'] as int? ?? 1024,
        moodAura: json['moodAura'] as String? ?? 'Quiet Solitude 🌿',
        authorAlias: json['authorAlias'] as String? ?? 'Quiet Friend',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {'holding_space': 4, 'i_see_you': 6, 'gentle_love': 8},
        userReactions: (json['userReactions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toSet() ??
            {},
      );
}

class MoreThanWordsScreen extends StatefulWidget {
  const MoreThanWordsScreen({super.key});

  @override
  State<MoreThanWordsScreen> createState() => _MoreThanWordsScreenState();
}

class _MoreThanWordsScreenState extends State<MoreThanWordsScreen> {
  final ImagePicker _picker = ImagePicker();
  static const int maxUploadSizeBytes = 50 * 1024 * 1024; // 50MB limit

  List<VisualPost> _posts = [];
  bool _isLoading = true;

  static const List<Map<String, dynamic>> _auras = [
    {'name': 'Quiet Solitude 🌿', 'color': Color(0xFF2E6F60), 'bg': Color(0xFFE8F5E9)},
    {'name': 'Heavy Rain 🌧️', 'color': Color(0xFF1B75B9), 'bg': Color(0xFFE1F5FE)},
    {'name': 'Gentle Dusk 🌆', 'color': Color(0xFF870E65), 'bg': Color(0xFFF3E5F5)},
    {'name': 'Ray of Dawn 🌅', 'color': Color(0xFFFDA737), 'bg': Color(0xFFFFF8E1)},
    {'name': 'Emotional Waves 🌊', 'color': Color(0xFF1BB9B9), 'bg': Color(0xFFE0F7FA)},
    {'name': 'Holding On 🕯️', 'color': Color(0xFFCA0174), 'bg': Color(0xFFFCE4EC)},
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('more_than_words_posts');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        setState(() {
          _posts = decoded.map((e) => VisualPost.fromJson(e)).toList();
          _isLoading = false;
        });
        return;
      } catch (_) {}
    }

    // Default sanctuary visual seed items
    final defaults = [
      VisualPost(
        id: 'seed-1',
        mediaType: 'image',
        mediaPath: 'assets/logo.png',
        fileSizeBytes: 240000,
        moodAura: 'Ray of Dawn 🌅',
        authorAlias: 'Gentle Soul',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        reactions: {'holding_space': 14, 'i_see_you': 19, 'gentle_presence': 11},
        userReactions: {},
      ),
      VisualPost(
        id: 'seed-2',
        mediaType: 'image',
        mediaPath: 'assets/logo.png',
        fileSizeBytes: 310000,
        moodAura: 'Quiet Solitude 🌿',
        authorAlias: 'Silent Healer',
        timestamp: DateTime.now().subtract(const Duration(hours: 7)),
        reactions: {'holding_space': 22, 'i_see_you': 15, 'gentle_presence': 25},
        userReactions: {},
      ),
      VisualPost(
        id: 'seed-3',
        mediaType: 'image',
        mediaPath: 'assets/logo.png',
        fileSizeBytes: 420000,
        moodAura: 'Holding On 🕯️',
        authorAlias: 'Wandering Heart',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        reactions: {'holding_space': 31, 'i_see_you': 28, 'gentle_presence': 19},
        userReactions: {},
      ),
    ];

    setState(() {
      _posts = defaults;
      _isLoading = false;
    });
    _savePosts();
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_posts.map((p) => p.toJson()).toList());
    await prefs.setString('more_than_words_posts', jsonString);
  }

  Future<void> _pickAndUpload({required bool isVideo, required ImageSource source}) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source, imageQuality: 90);

      if (file == null) return;

      // ── 50 MB Upload Limit Validation ──────────────────────────────────
      final fileLength = await file.length();
      if (fileLength > maxUploadSizeBytes) {
        if (!mounted) return;
        final mbSize = (fileLength / (1024 * 1024)).toStringAsFixed(1);
        _showLimitDialog(mbSize);
        return;
      }

      if (!mounted) return;
      _showConfirmationSheet(file, fileLength, isVideo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFCA0174),
          content: Text('Could not access media: $e'),
        ),
      );
    }
  }

  void _showLimitDialog(String currentMb) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFCA0174), size: 28),
            SizedBox(width: 8),
            Text('Upload Limit: 50MB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your selected file is ${currentMb}MB, which exceeds the Serevo 50MB limit.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDDF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Please select a shorter video or compressed photo under 50MB to keep the sanctuary lightweight and fast for everyone.',
                style: TextStyle(fontSize: 12, color: Color(0xFF921966), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF921966))),
          ),
        ],
      ),
    );
  }

  void _showConfirmationSheet(XFile file, int bytes, bool isVideo) {
    String selectedAura = _auras[0]['name'] as String;
    final mbFormatted = (bytes / (1024 * 1024)).toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isVideo ? 'Post Video Feeling' : 'Post Visual Feeling',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2F3433),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1BB9B9).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$mbFormatted MB / 50MB max',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B75B9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'No words needed. Select an emotional aura to frame your feeling:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              // Media preview container
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: const Color(0xFF14110E),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!isVideo && !kIsWeb)
                        Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      else
                        const Icon(Icons.videocam_rounded, size: 54, color: Color(0xFFFDA737)),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isVideo ? 'VIDEO' : 'PHOTO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Select Mood Aura:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2F3433)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _auras.map((aura) {
                  final name = aura['name'] as String;
                  final isSelected = selectedAura == name;
                  return ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    selectedColor: const Color(0xFFCA0174),
                    backgroundColor: const Color(0xFFFAF7F2),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF2F3433),
                    ),
                    onSelected: (val) {
                      if (val) setSheetState(() => selectedAura = name);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _publishPost(
                    mediaPath: file.path,
                    mediaType: isVideo ? 'video' : 'image',
                    fileSizeBytes: bytes,
                    aura: selectedAura,
                  );
                },
                icon: const Icon(Icons.favorite_rounded, color: Colors.white),
                label: const Text(
                  'Release Into Sanctuary',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCA0174),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _publishPost({
    required String mediaPath,
    required String mediaType,
    required int fileSizeBytes,
    required String aura,
  }) {
    final newPost = VisualPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mediaType: mediaType,
      mediaPath: mediaPath,
      fileSizeBytes: fileSizeBytes,
      moodAura: aura,
      authorAlias: 'You',
      timestamp: DateTime.now(),
      reactions: {'holding_space': 1, 'i_see_you': 1, 'gentle_presence': 1},
      userReactions: {'holding_space'},
    );

    setState(() {
      _posts.insert(0, newPost);
    });
    _savePosts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF921966),
        content: Text('Your visual feeling has been released with care. 🌸'),
      ),
    );
  }

  void _toggleReaction(VisualPost post, String reactionKey) {
    setState(() {
      if (post.userReactions.contains(reactionKey)) {
        post.userReactions.remove(reactionKey);
        post.reactions[reactionKey] = (post.reactions[reactionKey] ?? 1) - 1;
      } else {
        post.userReactions.add(reactionKey);
        post.reactions[reactionKey] = (post.reactions[reactionKey] ?? 0) + 1;
      }
    });
    _savePosts();
  }

  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'More Than Words',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2F3433),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCA0174).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Max 50MB',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFCA0174),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Express your state without needing words. Pick a photo or video under 50MB.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA770).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFFFF7235)),
                ),
                title: const Text('Photo from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Share a snapshot, artwork, or scene'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUpload(isVideo: false, source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1BB9B9).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Color(0xFF1B75B9)),
                ),
                title: const Text('Video from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Share a quiet clip or motion (up to 50MB)'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUpload(isVideo: true, source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCA0174).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFCA0174)),
                ),
                title: const Text('Take a Quick Photo', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Capture your surroundings in the present moment'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUpload(isVideo: false, source: ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF14110E) : const Color(0xFFFAF7F2),
      appBar: const SisonkeAppBar(title: 'More Than Words'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMediaPickerOptions,
        backgroundColor: const Color(0xFFCA0174),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text(
          'Post Visual (50MB)',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.3),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Sanctuary Banner Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF921966), Color(0xFFCA0174), Color(0xFFFDA737)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCA0174).withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'NON-VERBAL SANCTUARY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.cloud_upload_outlined, size: 12, color: Colors.white70),
                                    SizedBox(width: 4),
                                    Text(
                                      '50MB limit',
                                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'When words are too heavy,\nlet imagery speak.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Post photos or videos without having to explain yourself. Community reacts with gentle space and quiet solidarity.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Feed Grid / List ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = _posts[index];
                        return _buildPostCard(post, isDark);
                      },
                      childCount: _posts.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPostCard(VisualPost post, bool isDark) {
    final cardBg = isDark ? const Color(0xFF241E1A) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF382E28) : const Color(0xFFF0E7DE);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author + Mood Aura Pill + Time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFCA0174).withValues(alpha: 0.15),
                      child: Text(
                        post.authorAlias == 'You' ? '🌸' : '🌿',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorAlias,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : SisonkeColors.charcoal,
                          ),
                        ),
                        Text(
                          _timeAgo(post.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: (isDark ? Colors.white : SisonkeColors.charcoal).withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDA737).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    post.moodAura,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF921966),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Visual content
          GestureDetector(
            onTap: () => _viewFullScreen(post),
            child: Container(
              height: 240,
              width: double.infinity,
              color: isDark ? const Color(0xFF14110E) : const Color(0xFFF0E7DE),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildMediaImage(post),
                  if (post.mediaType == 'video')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                    ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(post.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Empathetic Non-Verbal Reaction Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildReactionButton(
                  post: post,
                  keyName: 'holding_space',
                  emoji: '🫂',
                  label: 'Holding Space',
                  count: post.reactions['holding_space'] ?? 0,
                  isDark: isDark,
                ),
                _buildReactionButton(
                  post: post,
                  keyName: 'i_see_you',
                  emoji: '👁️',
                  label: 'I See You',
                  count: post.reactions['i_see_you'] ?? 0,
                  isDark: isDark,
                ),
                _buildReactionButton(
                  post: post,
                  keyName: 'gentle_presence',
                  emoji: '🤍',
                  label: 'With You',
                  count: post.reactions['gentle_presence'] ?? 0,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaImage(VisualPost post) {
    if (post.mediaPath.startsWith('assets/')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Image.asset(
            post.mediaPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 48),
          ),
        ),
      );
    }

    if (!kIsWeb && File(post.mediaPath).existsSync()) {
      return Image.file(
        File(post.mediaPath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey),
        ),
      );
    }

    return Center(
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        height: 120,
      ),
    );
  }

  Widget _buildReactionButton({
    required VisualPost post,
    required String keyName,
    required String emoji,
    required String label,
    required int count,
    required bool isDark,
  }) {
    final hasReacted = post.userReactions.contains(keyName);

    return InkWell(
      onTap: () => _toggleReaction(post, keyName),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: hasReacted
              ? const Color(0xFFCA0174).withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF2C241F) : const Color(0xFFFAF7F2)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasReacted ? const Color(0xFFCA0174) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: hasReacted ? FontWeight.w900 : FontWeight.w600,
                color: hasReacted
                    ? const Color(0xFFCA0174)
                    : (isDark ? Colors.white70 : SisonkeColors.charcoal.withValues(alpha: 0.7)),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: hasReacted
                      ? const Color(0xFFCA0174)
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _viewFullScreen(VisualPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(post.moodAura, style: const TextStyle(fontSize: 16)),
          ),
          body: Center(
            child: Hero(
              tag: post.id,
              child: _buildMediaImage(post),
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
