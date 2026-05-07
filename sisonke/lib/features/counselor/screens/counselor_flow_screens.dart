import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/shared/widgets/index.dart';

class CounselorRequestScreen extends StatefulWidget {
  final String? initialMethod;

  const CounselorRequestScreen({super.key, this.initialMethod});

  @override
  State<CounselorRequestScreen> createState() => _CounselorRequestScreenState();
}

class _CounselorRequestScreenState extends State<CounselorRequestScreen> {
  final _api = ApiService();
  final _summary = TextEditingController();
  var _category = 'Feeling overwhelmed';
  var _riskLevel = 'medium';
  late String _contactMethod;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _contactMethod = widget.initialMethod ?? 'live_chat';
  }

  @override
  void dispose() {
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Request Counselor'),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          Text(
            'What kind of support do you need?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _FlowCard(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                    labelText: 'Category',
                  ),
                  items:
                      const [
                            'Feeling overwhelmed',
                            'Relationship pressure',
                            'SRHR question',
                            'Substance use',
                            'Feeling unsafe',
                            'Other',
                          ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() {
                    _category = value ?? _category;
                    _riskLevel = _category == 'Feeling unsafe'
                        ? 'high'
                        : _riskLevel;
                  }),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'low', label: Text('Low')),
                    ButtonSegment(value: 'medium', label: Text('Medium')),
                    ButtonSegment(value: 'high', label: Text('High')),
                  ],
                  selected: {_riskLevel},
                  onSelectionChanged: (value) =>
                      setState(() => _riskLevel = value.first),
                ),
                if (widget.initialMethod == null) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _contactMethod,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.contact_support_rounded),
                      labelText: 'Preferred contact method',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'live_chat',
                        child: Text('Live chat'),
                      ),
                      DropdownMenuItem(
                        value: 'leave_message',
                        child: Text('Leave message'),
                      ),
                      DropdownMenuItem(
                        value: 'voice_note',
                        child: Text('Voice note'),
                      ),
                      DropdownMenuItem(
                        value: 'callback',
                        child: Text('Callback request'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _contactMethod = value ?? _contactMethod),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _summary,
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: _contactMethod == 'voice_note'
                        ? 'Optional: What is this voice note about?'
                        : _contactMethod == 'callback'
                            ? 'Optional: What should we call you about?'
                            : 'What should the counselor know?',
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.support_agent_rounded),
            label: Text(
              _contactMethod == 'voice_note'
                  ? 'Continue to record voice note'
                  : _contactMethod == 'callback'
                      ? 'Continue to number input'
                      : 'Create tracked case',
            ),
          ),
          const SizedBox(height: 12),
          const _FlowHint(
            text:
                'After the case is created, you can add a voice note, callback number, or message while waiting for a counselor.',
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final response = await _api.requestCounselor(
        issueCategory: _category,
        summary: _summary.text,
        riskLevel: _riskLevel,
        preferredContactMethod: _contactMethod,
      );
      final caseId = response['case']?['id'];
      if (!mounted || caseId == null) return;
      if (_contactMethod == 'callback') {
        context.pushReplacement('/callback-request/$caseId');
        return;
      }
      if (_contactMethod == 'voice_note') {
        context.pushReplacement('/voice-note-request/$caseId');
        return;
      }
      context.pushReplacement('/counselor-request-status/$caseId');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class CounselorRequestStatusScreen extends StatefulWidget {
  final String caseId;

  const CounselorRequestStatusScreen({super.key, required this.caseId});

  @override
  State<CounselorRequestStatusScreen> createState() =>
      _CounselorRequestStatusScreenState();
}

class _CounselorRequestStatusScreenState
    extends State<CounselorRequestStatusScreen> {
  final _api = ApiService();
  late Future<Map<String, dynamic>> _future = _api.getCounselorCase(
    widget.caseId,
  );
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() => _future = _api.getCounselorCase(widget.caseId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Request Status'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _RetryState(
              title: 'Could not load case status',
              body:
                  'Check your connection and try again. Your request is still safe on the server if it was created.',
              onRetry: () => setState(
                () => _future = _api.getCounselorCase(widget.caseId),
              ),
            );
          }
          final item = snapshot.data;
          final status = '${item?['status'] ?? 'requested'}';
          final risk =
              '${item?['riskLevel'] ?? item?['risk_level'] ?? 'medium'}';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusTimeline(status: status),
              if (status == 'requested') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE4DDF6,
                    ).withValues(alpha: 0.8), // lavender glow
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFC7BCE6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.self_improvement_rounded,
                            color: Color(0xFF7361A9),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'While you wait...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2F3433),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A counselor will be with you shortly. In the meantime, try a gentle, calming grounding exercise to steady your breath and body.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF2F3433),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7361A9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => context.push('/grounding'),
                              icon: const Icon(Icons.spa_outlined, size: 16),
                              label: const Text(
                                'Grounding',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF7361A9),
                                ),
                              ),
                              onPressed: () => context.push('/breathing'),
                              icon: const Icon(
                                Icons.air_rounded,
                                size: 16,
                                color: Color(0xFF7361A9),
                              ),
                              label: const Text(
                                'Breathe',
                                style: TextStyle(
                                  color: Color(0xFF7361A9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _FlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item?['issueCategory'] ?? item?['issue_category'] ?? 'Support request'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(status)),
                        Chip(label: Text('$risk risk')),
                      ],
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: ['assigned', 'accepted', 'live'].contains(status)
                    ? () => context.push(
                        '/live-chat/${widget.caseId}',
                        extra: {'title': 'Counselor support'},
                      )
                    : null,
                icon: const Icon(Icons.chat_bubble_rounded),
                label: const Text('Open chat'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/voice-note-request/${widget.caseId}'),
                icon: const Icon(Icons.mic_rounded),
                label: const Text('Leave voice note'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/callback-request/${widget.caseId}'),
                icon: const Icon(Icons.call_rounded),
                label: const Text('Request callback'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/emergency-escalation/${widget.caseId}'),
                icon: const Icon(Icons.priority_high_rounded),
                label: const Text('Escalate'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(
                  () => _future = _api.getCounselorCase(widget.caseId),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh status'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CallbackRequestScreen extends StatefulWidget {
  final String caseId;

  const CallbackRequestScreen({super.key, required this.caseId});

  @override
  State<CallbackRequestScreen> createState() => _CallbackRequestScreenState();
}

class _CallbackRequestScreenState extends State<CallbackRequestScreen> {
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _api = ApiService();
  var _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RequestTypeScaffold(
      title: 'Callback Request',
      icon: Icons.call_rounded,
      children: [
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Safe phone number',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Best time or notes',
            prefixIcon: Icon(Icons.schedule_rounded),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Request callback'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await _api.requestCaseCallback(
        caseId: widget.caseId,
        callbackPhone: _phone.text,
      );
      if (_notes.text.trim().isNotEmpty) {
        await _api.sendCaseMessage(
          caseId: widget.caseId,
          content: 'Callback note: ${_notes.text.trim()}',
          messageType: 'text',
        );
      }
      if (!mounted) return;
      context.pushReplacement('/counselor-request-status/${widget.caseId}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class VoiceNoteRecorderScreen extends StatefulWidget {
  final String caseId;

  const VoiceNoteRecorderScreen({super.key, required this.caseId});

  @override
  State<VoiceNoteRecorderScreen> createState() =>
      _VoiceNoteRecorderScreenState();
}

class _VoiceNoteRecorderScreenState extends State<VoiceNoteRecorderScreen> {
  final _notes = TextEditingController();
  final _api = ApiService();
  var _recording = false;
  var _loading = false;

  Timer? _timer;
  int _recordDuration = 0;
  final List<double> _waveform = [];
  final _random = math.Random();
  Timer? _waveformTimer;

  void _startRecording() {
    setState(() {
      _recording = true;
      _recordDuration = 0;
      _waveform.clear();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordDuration++;
        });
      }
    });
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _waveform.add(_random.nextDouble() * 0.8 + 0.2);
          if (_waveform.length > 30) {
            _waveform.removeAt(0);
          }
        });
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _waveformTimer?.cancel();
    setState(() {
      _recording = false;
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _notes.dispose();
    _timer?.cancel();
    _waveformTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RequestTypeScaffold(
      title: 'Voice Note',
      icon: Icons.mic_rounded,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_recording) ...[
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _waveform.map((amp) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 4,
                        height: math.max(6.0, amp * 50.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE63946),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDuration(_recordDuration),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE63946),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              IconButton.filled(
                iconSize: 48,
                style: IconButton.styleFrom(
                  backgroundColor: _recording ? const Color(0xFFE63946) : const Color(0xFF2E6F60),
                ),
                onPressed: () {
                  if (_recording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
                icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
              ),
              const SizedBox(height: 8),
              Text(_recording ? 'Recording voice note...' : 'Tap to record'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _notes,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Optional note',
            prefixIcon: Icon(Icons.notes_rounded),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E6F60),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.send_rounded),
          label: const Text('Upload voice note'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    _stopRecording();
    setState(() => _loading = true);
    try {
      await _api.sendCaseMessage(
        caseId: widget.caseId,
        content: _notes.text.trim().isEmpty
            ? 'Voice note submitted'
            : _notes.text.trim(),
        messageType: 'voice_note',
        mediaUrl:
            'local-placeholder://voice-note/${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!mounted) return;
      context.pushReplacement('/counselor-request-status/${widget.caseId}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  final _api = ApiService();
  late Future<List<Map<String, dynamic>>> _future = _api.getMyCounselorCases();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Case History'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _RetryState(
              title: 'Could not load case history',
              body: 'Try again when your connection is stable.',
              onRetry: () =>
                  setState(() => _future = _api.getMyCounselorCases()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No counselor cases yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              final id = '${item['id']}';
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.folder_shared_rounded),
                  title: Text(
                    '${item['issueCategory'] ?? item['issue_category'] ?? 'Support'}',
                  ),
                  subtitle: Text('${item['status']}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/counselor-request-status/$id'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EmergencyEscalationScreen extends StatelessWidget {
  final String caseId;

  const EmergencyEscalationScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return _RequestTypeScaffold(
      title: 'Emergency Escalation',
      icon: Icons.priority_high_rounded,
      children: [
        const Text(
          'If you are in immediate danger, use emergency contacts now.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push('/emergency'),
          icon: const Icon(Icons.health_and_safety_rounded),
          label: const Text('Open emergency toolkit'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.push('/callback-request/$caseId'),
          icon: const Icon(Icons.call_rounded),
          label: const Text('Ask counselor to call me'),
        ),
      ],
    );
  }
}

class _RequestTypeScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _RequestTypeScaffold({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(title: title),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _FlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  final Widget child;

  const _FlowCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _FlowHint extends StatelessWidget {
  final String text;

  const _FlowHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _RetryState extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onRetry;

  const _RetryState({
    required this.title,
    required this.body,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 44,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = const [
      'requested',
      'assigned',
      'accepted',
      'live',
      'waiting_for_client',
      'callback_requested',
      'follow_up',
      'escalated',
      'resolved',
      'closed',
    ];
    final current = steps.indexOf(status).clamp(0, steps.length - 1);
    return _FlowCard(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: i <= current
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: i <= current
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _labelFor(steps[i]),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: i == current ? FontWeight.w800 : null,
                    ),
                  ),
                ),
              ],
            ),
            if (i != steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 14,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _labelFor(String value) {
    return switch (value) {
      'waiting_for_client' => 'Waiting for client',
      'callback_requested' => 'Callback requested',
      'follow_up' => 'Follow-up',
      'escalated' => 'Escalated',
      _ => value[0].toUpperCase() + value.substring(1),
    };
  }
}
