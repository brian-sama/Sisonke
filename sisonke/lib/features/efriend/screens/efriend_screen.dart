import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class EFriendScreen extends StatefulWidget {
  const EFriendScreen({super.key});

  @override
  State<EFriendScreen> createState() => _EFriendScreenState();
}

class _EFriendScreenState extends State<EFriendScreen>
    with SingleTickerProviderStateMixin {
  var _persona = 'female'; // 'female' (Felicia) or 'male' (Feelix)
  final _api = ApiService();
  final _messages = <_ChatMessage>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _sessionId;
  var _sending = false;
  String _trustedContactName = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<_PromptTopic> _promptTopics = const [
    _PromptTopic(
      label: 'Anxiety & Overthinking',
      icon: Icons.spa_outlined,
      color: Color(0xFF1BB9B9), // Serevo Teal
      prompt: "I'm stuck in an overthinking loop right now. Can you help me calm my thoughts?",
    ),
    _PromptTopic(
      label: 'Feeling Low',
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFFCA0174), // Serevo Magenta
      prompt: "I've been feeling low and exhausted today. Can we just talk for a few minutes?",
    ),
    _PromptTopic(
      label: 'Breathing Pause',
      icon: Icons.air_rounded,
      color: Color(0xFF1B75B9), // Serevo Blue
      prompt: "Can you guide me through a gentle 2-minute calming breathing exercise?",
    ),
    _PromptTopic(
      label: 'School & Work Stress',
      icon: Icons.school_outlined,
      color: Color(0xFFFDA737), // Serevo Amber
      prompt: "I'm feeling really stressed about expectations and responsibilities.",
    ),
    _PromptTopic(
      label: 'Relationships',
      icon: Icons.favorite_outline_rounded,
      color: Color(0xFFEE2B5E), // Serevo Hot Pink
      prompt: "I'm having a hard time communicating with someone I care about.",
    ),
    _PromptTopic(
      label: 'Gratitude & Hope',
      icon: Icons.light_mode_outlined,
      color: Color(0xFF6F206F), // Serevo Purple
      prompt: "Can you help me find one small positive thing to focus on today?",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedPersona = prefs.getString('user_persona');
    setState(() {
      if (savedPersona == 'male' || savedPersona == 'female') {
        _persona = savedPersona!;
      }
      _trustedContactName = prefs.getString('trusted_contact_name') ?? '';
    });
  }

  Future<void> _setPersona(String newPersona) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_persona', newPersona);
    if (!mounted) return;
    setState(() => _persona = newPersona);
  }

  BoxDecoration _backgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F1713),
            Color(0xFF14241D),
            Color(0xFF0F1813),
          ],
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF2F9F4),
          Color(0xFFEAF5EE),
          Color(0xFFDFF1E6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isChatEmpty = _messages.isEmpty;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1713) : const Color(0xFFF2F9F4),
      body: Container(
        decoration: _backgroundDecoration(context),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Bar ───────────────────────────────────────────
              _buildTopBar(context, isDark),

              // ── Main Content Area ─────────────────────────────────
              Expanded(
                child: isChatEmpty
                    ? _buildWelcomeHero(context, isDark)
                    : _buildMessageList(context, isDark),
              ),

              // ── Category / Suggestion Chips ───────────────────────
              _buildCategoryChips(context, isDark),

              const SizedBox(height: 8),

              // ── Floating Input Dock ───────────────────────────────
              _buildFloatingInputDock(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Navigation Bar ──────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1B2921) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button
          _CircleButton(
            backgroundColor: cardBg,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).maybePop();
              } else {
                context.go('/home');
              }
            },
            child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 20),
          ),

          // Center Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.auto_awesome_rounded,
                        size: 15,
                        color: Color(0xFFCA0174),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _persona == 'female' ? 'Felicia • Serevo' : 'Feelix • Serevo',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),

          // Circular Menu Button
          _CircleButton(
            backgroundColor: cardBg,
            onPressed: () => _showOptionsSheet(context),
            child: Icon(Icons.menu_rounded, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Welcome Hero ────────────────────────────────────────────────────
  Widget _buildWelcomeHero(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF14241C);

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Animated Concentric Glow Rings with Mascot
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final scale = _pulseAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer faint glowing ring
                    Container(
                      width: 146 * scale,
                      height: 146 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF86EFAC).withValues(
                          alpha: isDark ? 0.08 : 0.22,
                        ),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: 116 * scale,
                      height: 116 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4ADE80).withValues(
                          alpha: isDark ? 0.16 : 0.40,
                        ),
                      ),
                    ),
                    // Inner bright green mascot badge
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF42E046),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(
                              alpha: isDark ? 0.4 : 0.35,
                            ),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: _RobotMascot(size: 44),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 38),

            // Big Bold Headline
            Text(
              'How Can I Help\nYou Today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
                height: 1.15,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            // Friendly subtext
            Text(
              "I'm ${_persona == 'female' ? 'Felicia' : 'Feelix'}, your private, caring companion. Ask any question or share what is on your heart.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.65),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Chat Message List ───────────────────────────────────────────────
  Widget _buildMessageList(BuildContext context, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemCount: _messages.length + (_sending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const _BotTypingRow();
        }
        final message = _messages[index];
        return _MessageBubbleRow(
          message: message,
          persona: _persona,
          isDark: isDark,
          onCounselorTap: () => context.push('/talk-to-counselor'),
        );
      },
    );
  }

  // ── Category / Suggestion Chips ─────────────────────────────────────
  Widget _buildCategoryChips(BuildContext context, bool isDark) {
    final chipBg = isDark ? const Color(0xFF1B2921) : Colors.white;
    final chipBorder = isDark ? const Color(0xFF2C3E34) : const Color(0xFFE2EBE5);
    final textColor = isDark ? Colors.white70 : const Color(0xFF334155);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _promptTopics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final topic = _promptTopics[index];
          return InkWell(
            onTap: () => _usePrompt(topic.prompt),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: chipBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(topic.icon, size: 15, color: topic.color),
                  const SizedBox(width: 6),
                  Text(
                    topic.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Floating Input Dock ─────────────────────────────────────────────
  Widget _buildFloatingInputDock(BuildContext context, bool isDark) {
    final dockBg = isDark ? const Color(0xFF1B2921) : Colors.white;
    final dockBorder = isDark ? const Color(0xFF2C3E34) : const Color(0xFFE2EBE5);
    final subIconColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: dockBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: dockBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Empathy Input Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // [+] Wellness & Crisis Tools
                  InkWell(
                    onTap: () => _showPlusToolsSheet(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF261922) : const Color(0xFFFAF0F4),
                        border: Border.all(color: dockBorder),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: const Color(0xFFCA0174),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Prompt TextField
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF24141E),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        hintText: "Message ${_persona == 'female' ? 'Felicia' : 'Feelix'}...",
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Mic Button
                  InkWell(
                    onTap: _toggleVoiceHint,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: dockBorder),
                      ),
                      child: Icon(
                        Icons.mic_none_rounded,
                        size: 19,
                        color: subIconColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Vibrant Serevo Magenta Send Button
                  InkWell(
                    onTap: _sending ? null : _send,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEE2B5E), Color(0xFFCA0174)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCA0174).withValues(
                              alpha: isDark ? 0.35 : 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _sending
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.near_me_rounded,
                                size: 19,
                                color: Colors.white,
                              ),
                            ),
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

  // ── Helper Actions ──────────────────────────────────────────────────
  void _usePrompt(String prompt) {
    _controller.text = prompt;
    _send();
  }

  void _toggleVoiceHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input: Speak clearly or type your question below.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final apiMessage = text;
    setState(() {
      _sending = true;
      _messages.add(_ChatMessage(fromUser: true, text: text, risk: 'CHECKING'));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await _api.sendChatbotMessage(
        message: apiMessage,
        persona: _persona,
        sessionId: _sessionId,
      );
      final risk = '${response['riskLevel'] ?? 'low'}'.toUpperCase();
      final reply = '${response['reply']}';
      _sessionId = response['sessionId'] as String?;

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(fromUser: false, text: reply, risk: risk));
        _sending = false;
      });
      _scrollToBottom();

      if (response['escalationRequired'] == true && mounted) {
        context.push('/crisis-pathway');
      }
    } catch (_) {
      final risk = _riskFor(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            fromUser: false,
            text: risk == 'HIGH'
                ? "I hear how much pain you are carrying right now. You are not alone, and I want you to be safe. Let's connect you with human support who truly care."
                : "I could not reach my network right now, but please take a gentle, deep breath. I'm right here with you.",
            risk: risk,
          ),
        );
        _sending = false;
      });
      _scrollToBottom();
      if (risk == 'HIGH' && mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.push('/crisis-pathway');
      }
    }
  }

  String _riskFor(String value) {
    final text = value.toLowerCase();
    const highTerms = [
      'suicide',
      'kill myself',
      'end my life',
      'want to die',
      'no reason to live',
      'hurt myself',
      'harm myself',
      'going to end it',
      'nothing to live for',
      'don\'t want to wake up',
      'want to sleep forever',
      'rape',
      'sexual abuse',
      'being abused',
      'kuzviuraya',
      'ndinoda kufa',
      'ndakasuwa',
      'ndinovimba kuuraya',
      'ngifuna ukufa',
      'angisafuni ukuphila',
      'ngiyabhubha',
      'uyangishaya',
      'bangishaya',
      'bronco syrup',
      'ngoma syrup',
      'codeine syrup',
    ];
    if (highTerms.any(text.contains)) return 'HIGH';
    return 'LOW';
  }

  // ── Bottom Sheets ───────────────────────────────────────────────────
  void _showOptionsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Companion Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                // Companion persona
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF42E046).withValues(alpha: 0.2),
                    child: const Icon(Icons.person_outline_rounded, color: Color(0xFF22C55E)),
                  ),
                  title: const Text('Companion Persona', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_persona == 'female' ? 'Felicia (Sister)' : 'Feelix (Brother)'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'female', label: Text('Felicia')),
                      ButtonSegment(value: 'male', label: Text('Feelix')),
                    ],
                    selected: {_persona},
                    onSelectionChanged: (val) {
                      _setPersona(val.first);
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),

                const Divider(),

                // Check on me
                if (_trustedContactName.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0E7FF),
                      child: Icon(Icons.volunteer_activism_outlined, color: Color(0xFF4F46E5)),
                    ),
                    title: Text('Notify $_trustedContactName'),
                    subtitle: const Text('Send a discreet wellness check-in request'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showCheckOnMeSheet(context);
                    },
                  ),

                // Human counselor
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.support_agent_rounded, color: Color(0xFF16A34A)),
                  ),
                  title: const Text('Talk to a Human Counselor'),
                  subtitle: const Text('Connect with certified mental health professionals'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/talk-to-counselor');
                  },
                ),

                // Clear conversation
                if (_messages.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFEE2E2),
                      child: Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                    ),
                    title: const Text('Clear Conversation', style: TextStyle(color: Color(0xFFDC2626))),
                    subtitle: const Text('Reset chat messages and start fresh'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _messages.clear();
                        _sessionId = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlusToolsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Support & Wellness Tools',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.self_improvement_rounded, color: Color(0xFF16A34A)),
                  ),
                  title: const Text('Calm Breathing Pause'),
                  subtitle: const Text('Take 60 seconds to regulate your heart rate'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/breathing');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE9FE),
                    child: Icon(Icons.edit_note_rounded, color: Color(0xFF7C3AED)),
                  ),
                  title: const Text('Journal My Feelings'),
                  subtitle: const Text('Write privately and reflect on your mood'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/check-in/journal');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEE2E2),
                    child: Icon(Icons.shield_outlined, color: Color(0xFFDC2626)),
                  ),
                  title: const Text('Crisis Pathway & Helplines'),
                  subtitle: const Text('Emergency support lines and immediate human safety'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/crisis-pathway');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCheckOnMeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Send a check-in to $_trustedContactName',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'This will let them know you could use a friendly check-in today.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SisonkeColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(sheetContext);
                    try {
                      await _api.post('/api/profiles/check-on-me', {});
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Your trusted contact has been notified.',
                          ),
                        ),
                      );
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not send check-in. Please try again when you are connected.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Send check-in',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Models & Visual Components ─────────────────────────────────────────

class _PromptTopic {
  final String label;
  final IconData icon;
  final Color color;
  final String prompt;

  const _PromptTopic({
    required this.label,
    required this.icon,
    required this.color,
    required this.prompt,
  });
}

class _ChatMessage {
  final bool fromUser;
  final String text;
  final String risk;

  const _ChatMessage({
    required this.fromUser,
    required this.text,
    required this.risk,
  });
}

class _CircleButton extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final VoidCallback onPressed;

  const _CircleButton({
    required this.backgroundColor,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Custom Robot Mascot Matching Screenshot ───────────────────────────
class _RobotMascot extends StatelessWidget {
  final double size;
  const _RobotMascot({this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RobotMascotPainter(),
    );
  }
}

class _RobotMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 40.0;
    final strokePaint = Paint()
      ..color = const Color(0xFF14241C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillDark = Paint()
      ..color = const Color(0xFF14241C)
      ..style = PaintingStyle.fill;

    // 1. Antenna stem & bulb
    canvas.drawLine(
      Offset(20 * scale, 10 * scale),
      Offset(20 * scale, 6 * scale),
      strokePaint,
    );
    canvas.drawCircle(Offset(20 * scale, 4.5 * scale), 2.2 * scale, fillDark);

    // 2. Ear studs
    canvas.drawLine(
      Offset(6.5 * scale, 20 * scale),
      Offset(8.5 * scale, 20 * scale),
      strokePaint,
    );
    canvas.drawLine(
      Offset(31.5 * scale, 20 * scale),
      Offset(33.5 * scale, 20 * scale),
      strokePaint,
    );

    // 3. Robot Head (rounded rectangle)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8.5 * scale, 10 * scale, 23 * scale, 19 * scale),
      Radius.circular(6 * scale),
    );
    canvas.drawRRect(headRect, strokePaint);

    // 4. Robot Eyes
    canvas.drawCircle(Offset(15.5 * scale, 18 * scale), 2.0 * scale, fillDark);
    canvas.drawCircle(Offset(24.5 * scale, 18 * scale), 2.0 * scale, fillDark);

    // 5. Smiling Mouth
    final mouthPath = Path()
      ..moveTo(16.5 * scale, 22.5 * scale)
      ..quadraticBezierTo(
        20 * scale,
        25.5 * scale,
        23.5 * scale,
        22.5 * scale,
      );
    canvas.drawPath(mouthPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Message Bubble Row ────────────────────────────────────────────────
class _MessageBubbleRow extends StatelessWidget {
  final _ChatMessage message;
  final String persona;
  final bool isDark;
  final VoidCallback onCounselorTap;

  const _MessageBubbleRow({
    required this.message,
    required this.persona,
    required this.isDark,
    required this.onCounselorTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    final isHighRisk = message.risk == 'HIGH';

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF22574A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    // Bot Response with mini avatar
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini Robot Avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF42E046),
            ),
            child: const Center(
              child: _RobotMascot(size: 20),
            ),
          ),

          // Message Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? (isHighRisk ? const Color(0xFF381F26) : const Color(0xFF1B2921))
                    : (isHighRisk ? const Color(0xFFFFF1F2) : Colors.white),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: isHighRisk
                      ? const Color(0xFFF43F5E).withValues(alpha: 0.5)
                      : (isDark ? const Color(0xFF2C3E34) : const Color(0xFFE2EBE5)),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                  if (isHighRisk) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.health_and_safety_rounded,
                          size: 16,
                          color: Color(0xFFF43F5E),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Please let us connect you with immediate human support.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF43F5E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF43F5E),
                        side: const BorderSide(color: Color(0xFFF43F5E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: onCounselorTap,
                      icon: const Icon(Icons.support_agent_rounded, size: 16),
                      label: const Text('Speak to a Counselor now'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bot Typing Indicator ──────────────────────────────────────────────
class _BotTypingRow extends StatefulWidget {
  const _BotTypingRow();

  @override
  State<_BotTypingRow> createState() => _BotTypingRowState();
}

class _BotTypingRowState extends State<_BotTypingRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF42E046),
            ),
            child: const Center(
              child: _RobotMascot(size: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2921) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3E34) : const Color(0xFFE2EBE5),
              ),
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.25;
                    final raw = (_animController.value - delay).clamp(0.0, 1.0);
                    final scale = 0.5 + (raw * 0.5);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7 * scale,
                      height: 7 * scale,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF42E046),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
