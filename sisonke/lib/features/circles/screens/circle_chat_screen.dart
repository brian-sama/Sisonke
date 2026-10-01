import 'package:flutter/material.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

class CircleChatScreen extends StatefulWidget {
  final String circleId;
  final String theme;

  const CircleChatScreen({
    super.key,
    required this.circleId,
    required this.theme,
  });

  @override
  State<CircleChatScreen> createState() => _CircleChatScreenState();
}

class _CircleChatScreenState extends State<CircleChatScreen> {
  final _api = ApiService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response =
          await _api.get('/api/circles/${widget.circleId}/messages');
      final List<dynamic> raw =
          response is List ? response : (response['messages'] ?? []);
      setState(() {
        _messages = raw.cast<Map<String, dynamic>>();
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = 'Could not load messages. Tap to retry.';
        _loading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    setState(() => _sending = true);
    try {
      await _api.post(
        '/api/circles/${widget.circleId}/messages',
        {'content': text},
      );
      await _loadMessages();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: SisonkeAppBar(title: widget.theme),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF10131C), Color(0xFF171B28)],
                )
              : SisonkeColors.morningMist,
        ),
        child: Column(
          children: [
            // ── Anonymity notice ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : SisonkeColors.secondaryDim,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 14,
                    color: isDark
                        ? theme.colorScheme.secondary
                        : SisonkeColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'All messages are anonymous',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.85)
                          : SisonkeColors.secondary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            // ── Messages ────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: GestureDetector(
                            onTap: _loadMessages,
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF2F3433).withValues(alpha:0.6),
                                ),
                              ),
                            ),
                          ),
                        )
                      : _messages.isEmpty
                          ? const _EmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return _AnonymousBubble(
                                  text: msg['content']?.toString() ?? '',
                                  timeLabel: msg['createdAt'] != null
                                      ? _formatTime(msg['createdAt'].toString())
                                      : '',
                                );
                              },
                            ),
            ),
            // ── Input bar ────────────────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(
                          color: isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share with the circle...',
                          hintStyle: TextStyle(
                            color: (isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D)).withValues(alpha: 0.55),
                            fontSize: 15,
                          ),
                          fillColor: isDark
                              ? theme.colorScheme.surfaceContainerHighest
                              : Colors.white,
                          prefixIcon: Icon(
                            Icons.groups_rounded,
                            color: isDark
                                ? theme.colorScheme.secondary
                                : SisonkeColors.secondary,
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? theme.colorScheme.secondary
                            : SisonkeColors.secondary,
                        foregroundColor: isDark
                            ? const Color(0xFF10131C)
                            : Colors.white,
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: _sending ? null : _sendMessage,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
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

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }
}

// ─── Anonymous message bubble ─────────────────────────────────────────────────
class _AnonymousBubble extends StatelessWidget {
  final String text;
  final String timeLabel;

  const _AnonymousBubble({required this.text, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                  : SisonkeColors.lavender,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 16,
              color: isDark
                  ? theme.colorScheme.secondary
                  : SisonkeColors.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHigh
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: isDark
                      ? theme.colorScheme.outlineVariant
                      : const Color(0xFFE2EBE7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : const Color(0xFF14213D),
                    ),
                  ),
                  if (timeLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : const Color(0xFF14213D).withValues(alpha: 0.5),
                      ),
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

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                    : SisonkeColors.lavender,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 40,
                color: isDark
                    ? theme.colorScheme.secondary
                    : SisonkeColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Be the first to share in this circle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your words stay here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: (isDark ? theme.colorScheme.onSurface : const Color(0xFF14213D)).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
