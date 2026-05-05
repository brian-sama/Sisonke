import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class CounselorMobileWorkspaceScreen extends StatefulWidget {
  const CounselorMobileWorkspaceScreen({super.key});

  @override
  State<CounselorMobileWorkspaceScreen> createState() =>
      _CounselorMobileWorkspaceScreenState();
}

class _CounselorMobileWorkspaceScreenState
    extends State<CounselorMobileWorkspaceScreen> {
  final _api = ApiService();
  late Future<List<Map<String, dynamic>>> _future = _api
      .getAssignedCounselorCases();
  var _availability = 'online';

  @override
  Widget build(BuildContext context) {
    return SisonkeScaffold(
      title: 'Counselor Mode',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            WellnessIllustrationCard(
              title: 'After-hours support',
              body:
                  'Manage assigned cases, replies, notes, callbacks, and escalations from this app.',
              icon: Icons.support_agent_rounded,
              color: SisonkeColors.mint,
            ),
            const SizedBox(height: 14),
            _AvailabilityCard(
              value: _availability,
              onChanged: _setAvailability,
            ),
            const SizedBox(height: 20),
            const SoftSectionHeader(
              title: 'Assigned cases',
              subtitle: 'Only cases assigned to you are shown here.',
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _StateCard(
                    icon: Icons.wifi_off_rounded,
                    title: 'Could not load assigned cases',
                    body: 'Check your connection and try again.',
                    actionLabel: 'Retry',
                    onAction: _refresh,
                  );
                }
                final cases = snapshot.data ?? const [];
                if (cases.isEmpty) {
                  return const _StateCard(
                    icon: Icons.inbox_rounded,
                    title: 'No assigned cases',
                    body: 'New assigned requests will appear here.',
                  );
                }
                return Column(
                  children: cases.map((item) {
                    return _AssignedCaseCard(
                      item: item,
                      onOpenChat: () => context.push(
                        '/live-chat/${item['id']}',
                        extra: {'title': 'Counselor support'},
                      ),
                      onAccept: () => _setStatus('${item['id']}', 'accepted'),
                      onLive: () => _setStatus('${item['id']}', 'live'),
                      onEscalate: () =>
                          _setStatus('${item['id']}', 'escalated'),
                      onFollowUp: () =>
                          _setStatus('${item['id']}', 'follow_up'),
                      onResolve: () => _setStatus('${item['id']}', 'resolved'),
                      onNote: () => _addNote('${item['id']}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _refresh() {
    setState(() => _future = _api.getAssignedCounselorCases());
  }

  Future<void> _setAvailability(String value) async {
    setState(() => _availability = value);
    try {
      await _api.setMyCounselorAvailability(
        status: value,
        isOnCall: value == 'online',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability could not be synced.')),
      );
    }
  }

  Future<void> _setStatus(String caseId, String status) async {
    await _api.updateCounselorCaseStatus(caseId: caseId, status: status);
    _refresh();
  }

  Future<void> _addNote(String caseId) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Case note'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(labelText: 'Private note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (note == null || note.trim().isEmpty) return;
    await _api.addCounselorCaseNote(caseId: caseId, note: note.trim());
    _refresh();
  }
}

class _AvailabilityCard extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _AvailabilityCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.circle_rounded, color: Colors.green),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Availability',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'online', label: Text('Online')),
                ButtonSegment(value: 'busy', label: Text('Busy')),
              ],
              selected: {value},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignedCaseCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onOpenChat;
  final VoidCallback onAccept;
  final VoidCallback onLive;
  final VoidCallback onEscalate;
  final VoidCallback onFollowUp;
  final VoidCallback onResolve;
  final VoidCallback onNote;

  const _AssignedCaseCard({
    required this.item,
    required this.onOpenChat,
    required this.onAccept,
    required this.onLive,
    required this.onEscalate,
    required this.onFollowUp,
    required this.onResolve,
    required this.onNote,
  });

  @override
  Widget build(BuildContext context) {
    final status = '${item['status']}';
    final risk = '${item['riskLevel'] ?? item['risk_level'] ?? 'medium'}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item['issueCategory'] ?? item['issue_category'] ?? 'Support request'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Chip(label: Text(status)),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('$risk risk')),
                Chip(label: Text('${item['source'] ?? 'mobile'}')),
              ],
            ),
            if (item['summary'] != null) ...[
              const SizedBox(height: 8),
              Text('${item['summary']}'),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onOpenChat,
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Chat'),
                ),
                OutlinedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Accept'),
                ),
                OutlinedButton.icon(
                  onPressed: onLive,
                  icon: const Icon(Icons.forum_rounded),
                  label: const Text('Live'),
                ),
                OutlinedButton.icon(
                  onPressed: onEscalate,
                  icon: const Icon(Icons.priority_high_rounded),
                  label: const Text('Escalate'),
                ),
                OutlinedButton.icon(
                  onPressed: onFollowUp,
                  icon: const Icon(Icons.event_available_rounded),
                  label: const Text('Follow-up'),
                ),
                OutlinedButton.icon(
                  onPressed: onNote,
                  icon: const Icon(Icons.note_add_rounded),
                  label: const Text('Note'),
                ),
                OutlinedButton.icon(
                  onPressed: onResolve,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Resolve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 38, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(body, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
