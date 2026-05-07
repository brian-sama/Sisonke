import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminder = false;
  bool _quickExitEnabled = true;
  bool _anonymousAnalytics = true;

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
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
              onChanged: (value) {
                setState(() => _quickExitEnabled = value);
                _setBool(AppConstants.quickExitEnabledKey, value);
              },
            ),
          ]),
          _buildSettingsSection(context, 'General', [
            _buildSettingsItem(
              context,
              'App Language',
              Icons.translate_rounded,
              () => context.push('/language'),
            ),
          ]),
          _buildSettingsSection(context, 'Notifications', [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_rounded),
              title: const Text('Daily reminder'),
              subtitle: const Text('Get a gentle check-in reminder.'),
              value: _dailyReminder,
              onChanged: (value) {
                setState(() => _dailyReminder = value);
                _setBool(AppConstants.enableNotificationsKey, value);
                _showSaved(context);
              },
            ),
          ]),
          _buildSettingsSection(context, 'Data', [
            SwitchListTile(
              secondary: const Icon(Icons.query_stats_rounded),
              title: const Text('Anonymous analytics'),
              subtitle: const Text(
                'Help improve Sisonke with aggregate, non-private usage signals.',
              ),
              value: _anonymousAnalytics,
              onChanged: (value) {
                setState(() => _anonymousAnalytics = value);
                _setBool(AppConstants.dataCollectionKey, value);
                _showSaved(context);
              },
            ),
            _buildSettingsItem(
              context,
              'Sync public content',
              Icons.sync_rounded,
              () => _showSaved(
                context,
                message:
                    'Sisonke will sync public content when you are online.',
              ),
            ),
            _buildSettingsItem(
              context,
              'Delete personal data',
              Icons.delete_outline_rounded,
              () => _showInfo(
                context,
                title: 'Delete personal data',
                body:
                    'A production account should support verified deletion of profile, counselor cases, device tokens, and private records. Journal and mood entries stored only on this device can be removed from the device.',
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
                    'Authorized exports should include case status, counselor notes visible to authorized staff, and safety timeline metadata without exposing private journal content.',
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
