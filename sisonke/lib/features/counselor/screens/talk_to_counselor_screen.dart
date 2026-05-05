import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/shared/widgets/index.dart';

class TalkToCounselorScreen extends StatelessWidget {
  const TalkToCounselorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Talk to Someone'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose the safest way to reach a counselor.',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _SupportOption(
            icon: Icons.support_agent_rounded,
            title: 'Start counselor request',
            body:
                'Choose a category, complete a risk check, and create a tracked case.',
            onTap: () => context.push('/counselor-request'),
          ),
          _SupportOption(
            icon: Icons.call_rounded,
            title: 'Request callback',
            body:
                'Create a counselor case first, then add a safe callback number.',
            onTap: () => context.push('/counselor-request'),
          ),
          _SupportOption(
            icon: Icons.mic_rounded,
            title: 'Send voice note',
            body: 'Create a case first, then leave a voice note on it.',
            onTap: () => context.push('/counselor-request'),
          ),
          _SupportOption(
            icon: Icons.history_rounded,
            title: 'Case history',
            body: 'Check previous requests, statuses, and follow-ups.',
            onTap: () => context.push('/case-history'),
          ),
          _SupportOption(
            icon: Icons.priority_high_rounded,
            title: 'Emergency escalation',
            body: 'Open urgent support options when safety cannot wait.',
            onTap: () => context.push('/emergency'),
          ),
        ],
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  const _SupportOption({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(body),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
