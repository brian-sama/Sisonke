import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dailyReminder = false;
  bool _quickExitEnabled = true;
  bool _anonymousAnalytics = true;
  String _trustedName = '';
  String _trustedPhone = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dailyReminder =
          prefs.getBool(AppConstants.enableNotificationsKey) ?? false;
      _quickExitEnabled =
          prefs.getBool(AppConstants.quickExitEnabledKey) ?? true;
      _anonymousAnalytics =
          prefs.getBool(AppConstants.dataCollectionKey) ?? true;
      _trustedName = prefs.getString('trusted_contact_name') ?? '';
      _trustedPhone = prefs.getString('trusted_contact_phone') ?? '';
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _showTrustedContactDialog(BuildContext context) async {
    final nameController = TextEditingController(text: _trustedName);
    final phoneController = TextEditingController(text: _trustedPhone);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Trusted Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Auntie Grace',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'e.g. +263 77 123 4567',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final messenger = ScaffoldMessenger.of(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('trusted_contact_name', name);
              await prefs.setString('trusted_contact_phone', phone);
              if (!mounted) return;
              setState(() {
                _trustedName = name;
                _trustedPhone = phone;
              });
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Trusted contact saved.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        children: [
          _buildSettingsSection(context, 'Privacy & Security', [
            _buildSettingsItem(
              context,
              'Privacy Center',
              Icons.lock_rounded,
              () => context.push('/settings/privacy'),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.exit_to_app_rounded),
              title: const Text('Quick Exit'),
              subtitle: const Text(
                'Keep the private exit button available on sensitive screens.',
              ),
              value: _quickExitEnabled,
              onChanged: (value) async {
                setState(() => _quickExitEnabled = value);
                await _setBool(AppConstants.quickExitEnabledKey, value);
                if (context.mounted) {
                  _showSaved(
                    context,
                    message: value ? 'Quick exit enabled.' : 'Quick exit disabled.',
                  );
                }
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.analytics_outlined),
              title: const Text('Anonymous Product Analytics'),
              subtitle: const Text(
                'Help us improve crisis support without ever logging personal chats or journals.',
              ),
              value: _anonymousAnalytics,
              onChanged: (value) async {
                setState(() => _anonymousAnalytics = value);
                await _setBool(AppConstants.dataCollectionKey, value);
                if (context.mounted) {
                  _showSaved(
                    context,
                    message: value ? 'Anonymous telemetry allowed.' : 'Telemetry opted out.',
                  );
                }
              },
            ),
          ]),
          _buildSettingsSection(context, 'Trusted Contacts & Notifications', [
            ListTile(
              leading: const Icon(Icons.volunteer_activism_rounded),
              title: const Text('Trusted contact for check-ins'),
              subtitle: Text(
                _trustedName.isNotEmpty
                    ? '$_trustedName ($_trustedPhone)'
                    : 'Add someone you trust for quick check-in alerts',
              ),
              trailing: const Icon(Icons.edit_rounded),
              onTap: () => _showTrustedContactDialog(context),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Gentle Daily Reminder'),
              subtitle: const Text('Receive a quiet morning or evening wellness check-in.'),
              value: _dailyReminder,
              onChanged: (value) async {
                setState(() => _dailyReminder = value);
                await _setBool(AppConstants.enableNotificationsKey, value);
                if (context.mounted) {
                  _showSaved(
                    context,
                    message: value ? 'Daily check-in reminders enabled.' : 'Daily reminders disabled.',
                  );
                }
              },
            ),
          ]),
          _buildSettingsSection(context, 'Data & Controls', [
            _buildSettingsItem(
              context,
              'Delete personal records',
              Icons.delete_outline_rounded,
              () => _showInfo(
                context,
                title: 'Delete personal data',
                body:
                    'A production account supports verified deletion of profile, counselor cases, device tokens, and private records. Journal and mood entries stored locally on this device can be cleared any time.',
              ),
            ),
            _buildSettingsItem(
              context,
              'Export my support report',
              Icons.ios_share_rounded,
              () => _showInfo(
                context,
                title: 'Export support report',
                body:
                    'Authorized exports include case status, counselor notes visible to authorized staff, and safety timeline metadata without exposing private journal content.',
              ),
            ),
          ]),
          _buildSettingsSection(context, 'About', [
            _buildSettingsItem(
              context,
              'About Sisonke',
              Icons.info_rounded,
              () => _showInfo(
                context,
                title: 'About Sisonke',
                body:
                    'Sisonke is a privacy-conscious mental health and SRHR support app. Emergency content works offline, and private journal/check-in data stays on your phone by default.',
              ),
            ),
            _buildSettingsItem(
              context,
              'Help & Support',
              Icons.help_rounded,
              () => context.push('/support'),
            ),
          ]),
        ],
      ),
    );
  }

  void _showSaved(BuildContext context, {String message = 'Setting saved'}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfo(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingSmall),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(child: Column(children: children)),
        const SizedBox(height: AppConstants.spacingMedium),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
