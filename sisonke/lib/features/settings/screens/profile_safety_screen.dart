import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/core/services/security_service.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

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
  var _autoLockSeconds = 30; // Matches PrivacyGuard defaults
  var _loading = true;
  var _saving = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _promptNewPin() async {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Create a Security PIN'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose a memorable 4-digit PIN to secure your safe space.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.length != 4) {
                      return 'Please enter a 4-digit PIN';
                    }
                    if (int.tryParse(val) == null) {
                      return 'PIN must contain only numbers';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter 4-digit PIN',
                    counterText: '',
                    prefixIcon: Icon(Icons.lock_rounded),
                  ),
                  style: const TextStyle(letterSpacing: 10, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() => _pinEnabled = false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  await _securityService.setPIN(pinController.text);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  setState(() => _pinEnabled = true);
                }
              },
              child: const Text('Set PIN'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Profile & Safety'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            _SettingsTile(
              icon: Icons.pin_rounded,
              title: 'PIN lock',
              subtitle: 'Required for private spaces',
              value: _pinEnabled,
              onChanged: (value) async {
                if (value) {
                  final hasPin = await _securityService.hasPIN();
                  if (!hasPin && mounted) {
                    await _promptNewPin();
                  } else {
                    setState(() => _pinEnabled = true);
                  }
                } else {
                  setState(() => _pinEnabled = false);
                }
              },
            ),
            _SettingsTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric unlock',
              subtitle: _biometricAvailable
                  ? 'Use device biometrics where available'
                  : 'Not available on this device or platform',
              value: _biometricEnabled,
              onChanged: _biometricAvailable
                  ? (value) => setState(() => _biometricEnabled = value)
                  : null,
            ),
            
            // Premium auto-lock selector
            Card(
              elevation: isDark ? 0 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-lock Timeout',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Timeout duration before locking',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<int>(
                      value: _autoLockSeconds,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _autoLockSeconds = value);
                        }
                      },
                      dropdownColor: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Immediately')),
                        DropdownMenuItem(value: 30, child: Text('30 seconds')),
                        DropdownMenuItem(value: 60, child: Text('1 minute')),
                        DropdownMenuItem(value: 300, child: Text('5 minutes')),
                        DropdownMenuItem(value: -1, child: Text('Never')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            _SettingsTile(
              icon: Icons.visibility_off_outlined,
              title: 'Hide journal preview',
              subtitle: 'Keep private reflections out of summaries',
              value: _hideJournalPreview,
              onChanged: (value) => setState(() => _hideJournalPreview = value),
            ),
            Card(
              elevation: isDark ? 0 : 1,
              child: ListTile(
                leading: Icon(
                  Icons.enhanced_encryption_rounded,
                  color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                ),
                title: const Text('Encrypted storage'),
                subtitle: const Text(
                  'Private data stays encrypted locally and is prepared for encrypted backend storage',
                ),
                trailing: const Icon(Icons.lock_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Save safety settings'),
            ),
            if (_notice != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surfaceContainer : SisonkeColors.mint.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.3) : SisonkeColors.sage,
                  ),
                ),
                child: Text(
                  _notice!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _biometricAvailable = biometricAvailable;
        _pinEnabled =
            profile?['pinEnabled'] as bool? ??
            profile?['pin_enabled'] as bool? ??
            prefs.getBool(AppConstants.pinEnabledKey) ??
            true;
        _biometricEnabled =
            biometricAvailable &&
            (profile?['biometricEnabled'] as bool? ??
                profile?['biometric_enabled'] as bool? ??
                prefs.getBool(AppConstants.biometricEnabledKey) ??
                false);
        _hideJournalPreview =
            profile?['hideJournalPreview'] as bool? ??
            profile?['hide_journal_preview'] as bool? ??
            true;
        
        // Load custom auto-lock timeout duration (default: 30s)
        _autoLockSeconds = prefs.getInt('auto_lock_duration_seconds') ?? 30;
        
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
      // Convert auto lock seconds to backend minutes parameter (for database compatibility)
      final backendMinutes = _autoLockSeconds == -1 ? 999 : (_autoLockSeconds / 60).round().clamp(1, 30);

      try {
        await _api.updateSafetySettings(
          pinEnabled: _pinEnabled,
          biometricEnabled: _biometricEnabled,
          autoLockMinutes: backendMinutes,
          hideJournalPreview: _hideJournalPreview,
        );
      } catch (e) {
        debugPrint('Backend safety settings update skipped: $e. Saved locally instead.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.pinEnabledKey, _pinEnabled);
      await prefs.setBool(
        AppConstants.biometricEnabledKey,
        _pinEnabled && _biometricEnabled,
      );
      await prefs.setInt('auto_lock_duration_seconds', _autoLockSeconds);

      if (!_pinEnabled) {
        await _securityService.clearPIN();
      }
      
      if (!mounted) return;
      setState(() {
        _saving = false;
        _notice = 'Safety settings saved successfully.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _notice = 'Could not save safety settings. Try again.';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 0 : 1,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
