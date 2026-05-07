import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

class EFriendScreen extends StatefulWidget {
  const EFriendScreen({super.key});

  @override
  State<EFriendScreen> createState() => _EFriendScreenState();
}

class _EFriendScreenState extends State<EFriendScreen> {
  var _persona = 'female';
  String? _emotion;
  final _api = ApiService();
  final _messages = <_ChatMessage>[
    const _ChatMessage(
      fromUser: false,
      text:
          'Take a slow, deep breath. I’m here to listen. Tell me what is on your mind today.',
      risk: 'LOW',
    ),
  ];
  final _controller = TextEditingController();
  String? _sessionId;
  var _sending = false;

  Gradient get _ambientBackground {
    if (_emotion == 'Sad' || _emotion == 'Lonely' || _emotion == 'Confused') {
      return SisonkeColors.morningMist;
    }
    if (_emotion == 'Anxious' || _emotion == 'Angry') {
      return SisonkeColors.pastelSunset;
    }
    return SisonkeColors.forestBreeze;
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Sisonke Friend',
        fallbackBackLocation: '/home',
        actions: [
          IconButton(
            icon: Icon(
              Icons.support_agent_rounded,
              color: _messages.any((m) => m.risk == 'HIGH')
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            tooltip: 'Speak to a human counselor',
            onPressed: () => context.push('/talk-to-counselor'),
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(gradient: _ambientBackground),
        child: Column(
          children: [
            if (!isKeyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'How are you arriving today?',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF2F3433),
                                  ),
                            ),
                          ),
                          // Soft style selection toggle
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'female',
                                icon: Icon(Icons.spa_outlined, size: 16),
                                label: Text(
                                  'Sister',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              ButtonSegment(
                                value: 'male',
                                icon: Icon(Icons.air_outlined, size: 16),
                                label: Text(
                                  'Brother',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                            selected: {_persona},
                            onSelectionChanged: (value) =>
                                setState(() => _persona = value.first),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            const [
                              'Sad',
                              'Anxious',
                              'Angry',
                              'Confused',
                              'Lonely',
                              'Okay',
                              'Happy',
                            ].map((emotion) {
                              return _EmotionChip(
                                emotion: emotion,
                                selected: _emotion == emotion,
                                onSelected: () => _selectEmotion(emotion),
                              );
                            }).toList(),
                      ),
                      if (_emotion != null) ...[
                        const SizedBox(height: 12),
                        _RiskCheckBanner(emotion: _emotion!),
                      ],
                    ],
                  ),
                ),
              ),

            // Render interactive floating companion when chat is quiet
            if (_messages.length <= 1 && !_sending)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isKeyboardVisible) ...[
                          _BreathingCompanion(persona: _persona),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'â€œType anything below to speak. I am your safe, private space.â€',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF2F3433).withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const _TypingBubble();
                    }
                    return _ChatBubble(message: _messages[index]);
                  },
                ),
              ),

            // Ambient Exercises Quick Row
            if (_messages.length > 1 && !isKeyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        onPressed: () => context.push('/breathing'),
                        icon: const Icon(
                          Icons.self_improvement_rounded,
                          color: Color(0xFF2E6F60),
                        ),
                        label: const Text(
                          'Breathe',
                          style: TextStyle(
                            color: Color(0xFF2F3433),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        onPressed: () => context.push('/private-journal'),
                        icon: const Icon(
                          Icons.edit_note_rounded,
                          color: Color(0xFF7361A9),
                        ),
                        label: const Text(
                          'Journal',
                          style: TextStyle(
                            color: Color(0xFF2F3433),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),



            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts...',
                          fillColor: Colors.white.withOpacity(0.85),
                          prefixIcon: const Icon(
                            Icons.favorite_outline_rounded,
                            color: Color(0xFF2E6F60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6F60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: _sending ? null : _send,
                      icon: const Icon(Icons.send_rounded),
                      tooltip: 'Send',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _sending = true;
      _messages.add(
        _ChatMessage(
          fromUser: true,
          text: _emotion == null ? text : 'I feel $_emotion. $text',
          risk: 'CHECKING',
        ),
      );
      _controller.clear();
    });

    try {
      final response = await _api.sendChatbotMessage(
        message: _emotion == null ? text : 'I feel $_emotion. $text',
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

      if (response['escalationRequired'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFD68A7F),
            content: Text(
              'I think you deserve some friendly human support right now. Consider chatting with a counselor.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } catch (_) {
      final risk = _riskFor(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            fromUser: false,
            text: risk == 'HIGH'
                ? 'I think you deserve warm human support right now. Please press the "I deserve counselor support" button above. I will stand with you until we connect.'
                : 'I couldn’t reach my system, but please take a slow breath. Your peace is what matters. Let’s try again when you are ready.',
            risk: risk,
          ),
        );
        _sending = false;
      });
    }
  }

  void _selectEmotion(String emotion) {
    setState(() {
      if (_emotion == emotion) {
        _emotion = null;
        return;
      }
      _emotion = emotion;
      _controller.text = _promptForEmotion(emotion);
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  String _riskFor(String value) {
    final text = value.toLowerCase();
    if ([
      'suicide',
      'kill myself',
      'hurt myself',
      'abuse',
      'violence',
      'unsafe',
    ].any(text.contains)) {
      return 'HIGH';
    }
    return 'LOW';
  }
}

class _EmotionChip extends StatelessWidget {
  final String emotion;
  final bool selected;
  final VoidCallback onSelected;

  const _EmotionChip({
    required this.emotion,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final companionColor = selected
        ? const Color(0xFF2E6F60)
        : const Color(0xFF2F3433).withOpacity(0.7);

    return ChoiceChip(
      label: Text(
        emotion,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF2F3433),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF2E6F60),
      backgroundColor: Colors.white.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      avatar: Icon(
        _iconFor(emotion),
        size: 18,
        color: selected ? Colors.white : companionColor,
      ),
      onSelected: (_) => onSelected(),
    );
  }

  IconData _iconFor(String value) {
    switch (value) {
      case 'Sad':
        return Icons.sentiment_dissatisfied_rounded;
      case 'Anxious':
        return Icons.air_rounded;
      case 'Angry':
        return Icons.local_fire_department_rounded;
      case 'Confused':
        return Icons.help_outline_rounded;
      case 'Lonely':
        return Icons.person_outline_rounded;
      case 'Happy':
        return Icons.sentiment_very_satisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }
}

String _promptForEmotion(String value) {
  switch (value) {
    case 'Anxious':
      return 'My body feels tense because ';
    case 'Angry':
      return 'I need help cooling down because ';
    case 'Lonely':
      return 'I feel alone and I need ';
    case 'Confused':
      return 'I am not sure what to do about ';
    case 'Sad':
      return 'I have been feeling low because ';
    case 'Happy':
      return 'I want to remember this good thing: ';
    default:
      return '';
  }
}

class _RiskCheckBanner extends StatelessWidget {
  final String emotion;

  const _RiskCheckBanner({required this.emotion});

  @override
  Widget build(BuildContext context) {
    final highAttention =
        emotion == 'Angry' || emotion == 'Sad' || emotion == 'Lonely';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highAttention
            ? const Color(0xFFFFEEF0).withOpacity(0.9)
            : const Color(0xFFE7FAFA).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highAttention
              ? const Color(0xFFFFCCD2)
              : const Color(0xFFCBEFF0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            highAttention
                ? Icons.health_and_safety_rounded
                : Icons.check_circle_rounded,
            color: highAttention
                ? const Color(0xFFD68A7F)
                : const Color(0xFF2E6F60),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              highAttention
                  ? 'I will stand with you and suggest friendly human support if needed.'
                  : 'I am here with you. Let’s explore some peaceful steps together.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: highAttention
                    ? const Color(0xFF8C4C42)
                    : const Color(0xFF1B4F43),
              ),
            ),
          ),
        ],
      ),
    );
  }
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

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF2E6F60).withOpacity(0.85) // primary glass
              : Colors.white.withOpacity(0.82), // white glass
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: message.risk == 'HIGH'
              ? Border.all(color: Colors.redAccent, width: 2)
              : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isUser ? Colors.white : const Color(0xFF2F3433),
              ),
            ),
            if (message.risk != 'LOW' && message.risk != 'CHECKING') ...[
              const SizedBox(height: 4),
              Text(
                'Safety Status: ${message.risk}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Stateful floating breathing companion widget
class _BreathingCompanion extends StatefulWidget {
  final String persona;
  const _BreathingCompanion({required this.persona});

  @override
  State<_BreathingCompanion> createState() => _BreathingCompanionState();
}

class _BreathingCompanionState extends State<_BreathingCompanion>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // 4-second slow breathing pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 6-second slow floating motion
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companionColor = widget.persona == 'female'
        ? const Color(0xFFEBCBD0) // blush
        : const Color(0xFFD8EEF8); // sky

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _floatController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer soft breathing glow aura
                  Container(
                    width: 90 * _pulseAnimation.value,
                    height: 90 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: companionColor.withOpacity(0.24),
                      boxShadow: [
                        BoxShadow(
                          color: companionColor.withOpacity(0.18),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  // Inner companion body
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: companionColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white60,
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(-2, -2),
                        ),
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🌱', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.persona == 'female'
                    ? 'Your Sister Companion'
                    : 'Your Brother Companion',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3433),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Beautiful asynchronous pulsing typing dots bubble
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final rawValue = _controller.value - delay;
                final value = math.sin(rawValue * math.pi).clamp(0.0, 1.0);
                final size = 6.0 + (value * 4.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF2E6F60,
                    ).withOpacity(0.3 + (value * 0.7)),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
