import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/features/emergency/providers/emergency_provider.dart';
import 'package:sisonke/shared/widgets/index.dart';

class SupportDirectoryScreen extends ConsumerWidget {
  const SupportDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(emergencyContactsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const SisonkeAppBar(
        title: 'Support',
        fallbackBackLocation: '/home',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _SupportHeader(
            onCounselor: () => context.push('/talk-to-counselor'),
            onEmergency: () => context.push('/emergency'),
          ),
          const SizedBox(height: 18),
          Text(
            'Talk to Someone',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.08,
            children: [
              _SupportAction(
                icon: Icons.support_agent_rounded,
                title: 'Talk to Someone',
                subtitle: 'Start tracked case',
                color: const Color(0xFFE7FAFA),
                onTap: () => context.push('/talk-to-counselor'),
              ),
              _SupportAction(
                icon: Icons.chat_bubble_rounded,
                title: 'Leave message',
                subtitle: 'Counselor replies later',
                color: const Color(0xFFFFF6D8),
                onTap: () => context.push('/counselor-request'),
              ),
              _SupportAction(
                icon: Icons.mic_rounded,
                title: 'Send voice note',
                subtitle: 'Create case first',
                color: const Color(0xFFF0EDFF),
                onTap: () => context.push('/counselor-request'),
              ),
              _SupportAction(
                icon: Icons.call_rounded,
                title: 'Request callback',
                subtitle: 'Safe number needed',
                color: const Color(0xFFFFEEF0),
                onTap: () => context.push('/counselor-request'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => context.push('/case-history'),
            icon: const Icon(Icons.folder_shared_rounded),
            label: const Text('View case status and history'),
          ),
          const SizedBox(height: 24),
          Text(
            'Emergency contacts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          contactsAsync.when(
            data: (response) {
              final categories = response.contacts.keys.toList();
              if (categories.isEmpty) {
                return const _SupportEmpty(text: 'No support contacts found.');
              }

              return Column(
                children: [
                  for (final category in categories)
                    _ContactGroup(
                      title:
                          AppConstants
                              .emergencyCategoryDisplayNames[category] ??
                          category.toUpperCase(),
                      contacts: response.contacts[category]!,
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) =>
                const _SupportEmpty(text: 'Could not load contacts.'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/emergency'),
        icon: const Icon(Icons.health_and_safety_rounded),
        label: const Text('Emergency'),
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  final VoidCallback onCounselor;
  final VoidCallback onEmergency;

  const _SupportHeader({required this.onCounselor, required this.onEmergency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7FAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: Color(0xFF00A6A6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Choose the support that fits this moment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCounselor,
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text('Talk'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEmergency,
                  icon: const Icon(Icons.warning_rounded),
                  label: const Text('Urgent help'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SupportAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF14213D)),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF14213D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF14213D).withValues(alpha: 0.65),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactGroup extends StatelessWidget {
  final String title;
  final List<dynamic> contacts;

  const _ContactGroup({required this.title, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final contact in contacts)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(contact.name),
                subtitle: Text(contact.description),
                trailing: IconButton(
                  icon: const Icon(Icons.call_rounded, color: Colors.green),
                  tooltip: 'Call',
                  onPressed: () => _makePhoneCall(contact.phoneNumber),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SupportEmpty extends StatelessWidget {
  final String text;

  const _SupportEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
