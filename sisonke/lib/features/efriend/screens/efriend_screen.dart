import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/services/api_service.dart';
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
      text: 'Choose a persona, then tell Sisonke Friend what is on your mind.',
      risk: 'LOW',
    ),
  ];
  final _controller = TextEditingController();
  String? _sessionId;
  var _sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Talk to Sisonke Friend'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'female',
                      icon: Icon(Icons.face_3_rounded),
                      label: Text('Sister'),
                    ),
                    ButtonSegment(
                      value: 'male',
                      icon: Icon(Icons.face_rounded),
                      label: Text('Brother'),
                    ),
                  ],
                  selected: {_persona},
                  onSelectionChanged: (value) =>
                      setState(() => _persona = value.first),
                ),
                const SizedBox(height: 14),
                Text(
                  'How are you arriving?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
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
                  const SizedBox(height: 10),
                  _RiskCheckBanner(emotion: _emotion!),
                ],
              ],
            ),
          ),
          if (_messages.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/breathing'),
                      icon: const Icon(Icons.self_improvement_rounded),
                      label: const Text('Breathe'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/private-journal'),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Journal'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _ChatBubble(message: _messages[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SisonkeButton(
              label: _messages.any((m) => m.risk == 'HIGH')
                  ? 'Talk to a real counselor now'
                  : 'Talk to a counselor',
              icon: Icons.support_agent_rounded,
              isFullWidth: true,
              onPressed: () => context.push('/talk-to-counselor'),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Message E-Friend',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    tooltip: 'Send',
                  ),
                ],
              ),
            ),
          ),
        ],
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
        // Automatically show the help button after a moment
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Safety alert: Connection to counselor recommended.'),
            duration: Duration(seconds: 5),
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
                ? 'This sounds serious. Please use the "Talk to Counselor" button now. I could not reach my full system, so I will not continue this alone.'
                : 'I could not reach the server, but I can still suggest a simple next step: pause, breathe, and try again when connected.',
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
    return ChoiceChip(
      label: Text(emotion),
      selected: selected,
      avatar: Icon(_iconFor(emotion), size: 18),
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
            ? const Color(0xFFFFEEF0)
            : const Color(0xFFE7FAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            highAttention
                ? Icons.health_and_safety_rounded
                : Icons.check_circle_rounded,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              highAttention
                  ? 'E-Friend will check safety and may suggest counselor support.'
                  : 'E-Friend will suggest a gentle next step.',
              style: const TextStyle(fontWeight: FontWeight.w700),
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
    final theme = Theme.of(context);
    final isUser = message.fromUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          border: message.risk == 'HIGH'
              ? Border.all(color: Colors.red, width: 2)
              : null,
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
                color: isUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
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
