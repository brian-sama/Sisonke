import 'package:flutter/material.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/core/services/security_service.dart';
import 'package:sisonke/shared/widgets/index.dart';

class ProfileSafetyScreen extends StatefulWidget {
  const ProfileSafetyScreen({super.key});

  @override
  State<ProfileSafetyScreen> createState() => _ProfileSafetyScreenState();
}

class _ProfileSafetyScreenState extends State<ProfileSafetyScreen> {
  final _api = ApiService();
  final _securityService = SecurityService();
  var _pinEnabled = true;
  var _biometricEnabled = false;
  var _biometricAvailable = false;
  var _hideJournalPreview = true;
  var _autoLockMinutes = 5;
  var _loading = true;
  var _saving = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Profile & Safety'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else ...[
            _SettingsTile(
              icon: Icons.pin_rounded,
              title: 'PIN lock',
              subtitle: 'Required for private spaces',
              value: _pinEnabled,
              onChanged: (value) => setState(() => _pinEnabled = value),
            ),
            _SettingsTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric unlock',
              subtitle: _biometricAvailable
                  ? 'Use device biometrics where available'
                  : 'Not available on this device or platform',
              value: _biometricEnabled,
              onChanged: _biometricAvailable ? (value) => setState(() => _biometricEnabled = value) : null,
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Auto-lock'),
                subtitle: Slider(
                  value: _autoLockMinutes.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$_autoLockMinutes min',
                  onChanged: (value) => setState(() => _autoLockMinutes = value.round()),
                ),
                trailing: Text('$_autoLockMinutes min'),
              ),
            ),
            _SettingsTile(
              icon: Icons.visibility_off_outlined,
              title: 'Hide journal preview',
              subtitle: 'Keep private reflections out of summaries',
              value: _hideJournalPreview,
              onChanged: (value) => setState(() => _hideJournalPreview = value),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.enhanced_encryption_rounded),
                title: Text('Encrypted storage'),
                subtitle: Text('Private data stays encrypted locally and is prepared for encrypted backend storage'),
                trailing: Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_rounded),
              label: const Text('Save safety settings'),
            ),
            if (_notice != null) ...[
              const SizedBox(height: 12),
              Text(_notice!),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _load() async {
    try {
      final biometricAvailable = await _securityService.isBiometricAvailable();
      final profile = await _api.getProfile();
      if (!mounted) return;
      setState(() {
        _biometricAvailable = biometricAvailable;
        _pinEnabled = profile?['pinEnabled'] as bool? ?? profile?['pin_enabled'] as bool? ?? true;
        _biometricEnabled = biometricAvailable &&
            (profile?['biometricEnabled'] as bool? ?? profile?['biometric_enabled'] as bool? ?? false);
        _hideJournalPreview = profile?['hideJournalPreview'] as bool? ?? profile?['hide_journal_preview'] as bool? ?? true;
        _autoLockMinutes = profile?['autoLockMinutes'] as int? ?? profile?['auto_lock_minutes'] as int? ?? 5;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _biometricAvailable = false;
        _biometricEnabled = false;
        _notice = 'Could not load profile safety settings.';
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _notice = null;
    });
    try {
      await _api.updateSafetySettings(
        pinEnabled: _pinEnabled,
        biometricEnabled: _biometricEnabled,
        autoLockMinutes: _autoLockMinutes,
        hideJournalPreview: _hideJournalPreview,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _notice = 'Safety settings saved.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _notice = 'Could not save. Complete onboarding first or check the backend.';
      });
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
