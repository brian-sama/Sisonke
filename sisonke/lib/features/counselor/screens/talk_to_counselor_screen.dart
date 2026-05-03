import 'package:flutter/material.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/shared/widgets/index.dart';

class TalkToCounselorScreen extends StatefulWidget {
  const TalkToCounselorScreen({super.key});

  @override
  State<TalkToCounselorScreen> createState() => _TalkToCounselorScreenState();
}

class _TalkToCounselorScreenState extends State<TalkToCounselorScreen> {
  final _api = ApiService();
  final _summary = TextEditingController();
  var _category = 'Feeling overwhelmed';
  var _requested = false;
  var _loading = false;
  String? _message;
  String? _caseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Talk to Someone'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('What do you need support with?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined), labelText: 'Issue category'),
            items: const [
              'Feeling overwhelmed',
              'Relationship pressure',
              'SRHR question',
              'Substance use',
              'Feeling unsafe',
              'Other',
            ].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) => setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summary,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What would you like the counselor to know?',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _requestCounselor,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.support_agent_rounded),
            label: const Text('Request counselor'),
          ),
          if (_requested) ...[
            const SizedBox(height: 20),
            _RequestInfoPanel(
              icon: Icons.mark_chat_unread_rounded,
              title: 'Request created',
              body: _message ?? 'The backend checked counselor availability and created a case.',
            ),
            if (_caseId != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('/live-chat/$_caseId', extra: {'title': _category}),
                icon: const Icon(Icons.chat_bubble_rounded),
                label: const Text('Start live chat session'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _requestCounselor() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final response = await _api.requestCounselor(
        issueCategory: _category,
        summary: _summary.text,
        riskLevel: _category == 'Feeling unsafe' ? 'high' : 'medium',
      );
      if (!mounted) return;
      setState(() {
        _requested = true;
        _caseId = response['case']?['id'];
        _message = '${response['message'] ?? 'Request created.'}';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _requested = true;
        _message = 'Could not reach the backend. Please try again, or use emergency support if you are unsafe.';
        _loading = false;
      });
    }
  }
}

class _RequestInfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _RequestInfoPanel({required this.icon, required this.title, required this.body});

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
