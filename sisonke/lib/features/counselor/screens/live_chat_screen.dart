import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/core/services/chat_service.dart';
import 'package:sisonke/shared/widgets/index.dart';

class LiveChatScreen extends ConsumerStatefulWidget {
  final String caseId;
  final String title;

  const LiveChatScreen({super.key, required this.caseId, required this.title});

  @override
  ConsumerState<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends ConsumerState<LiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final api = ApiService();
    final token = await api.getCurrentToken();
    final user = await api.getCurrentUser();

    if (token != null && mounted) {
      _userId = user?['id'];
      final chatService = ref.read(chatServiceProvider);
      chatService.connect(token);
      chatService.joinCase(widget.caseId);

      setState(() => _isConnected = true);

      // Listen for new messages
      chatService.messages.listen((msg) {
        if (msg['caseId'] == widget.caseId && mounted) {
          setState(() {
            _messages.add(msg);
          });
          _scrollToBottom();
        }
      });
    }
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

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'content': text,
        'senderId': _userId,
        'senderRole': 'user',
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
    });
    try {
      await ApiService().sendCaseMessage(caseId: widget.caseId, content: text);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message could not be saved.')),
      );
    }
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: widget.title,
        actions: [
          if (_isConnected)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.circle, color: Colors.green, size: 12),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const _SafetyNotice(),
          Expanded(
            child: _messages.isEmpty
                ? const _EmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['senderId'] == _userId;
                      return _ChatBubble(
                        content: msg['content'],
                        isMe: isMe,
                        role: msg['senderRole'] ?? 'user',
                      );
                    },
                  ),
          ),
          _InputArea(controller: _messageController, onSend: () => _send()),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF2C2214) : Colors.amber.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.security_rounded,
            size: 16,
            color: isDark ? const Color(0xFFFFB4AB) : Colors.amber,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Encrypted live support. Our counselors are here to help.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? theme.colorScheme.onSurface : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Waiting for counselor to join...',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String role;

  const _ChatBubble({
    required this.content,
    required this.isMe,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : (isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(18),
            bottomLeft: isMe
                ? const Radius.circular(18)
                : const Radius.circular(0),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: isDark
                      ? theme.colorScheme.outlineVariant
                      : Colors.grey.shade200,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isDark ? theme.colorScheme.secondary : theme.colorScheme.secondary,
                  ),
                ),
              ),
            Text(
              content,
              style: TextStyle(
                color: isMe
                    ? (isDark ? const Color(0xFF10131C) : Colors.white)
                    : (isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D)),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputArea({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? theme.colorScheme.outlineVariant : Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: (isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D)).withValues(alpha: 0.55),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outlineVariant : const Color(0xFFCCD5D1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outlineVariant : const Color(0xFFCCD5D1),
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
