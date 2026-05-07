import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/services/security_service.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _security = SecurityService();
  final _pin = TextEditingController();
  final _confirmPin = TextEditingController();
  var _hasPin = false;
  var _biometricEnabled = false;
  var _biometricAvailable = false;
  var _loading = true;
  var _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pin.dispose();
    _confirmPin.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPin = await _security.hasPIN();
    final biometricAvailable = await _security.isBiometricAvailable();
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _biometricAvailable = biometricAvailable;
      _biometricEnabled =
          biometricAvailable &&
          (prefs.getBool(AppConstants.biometricEnabledKey) ?? false);
      _loading = false;
    });

    if (hasPin && _biometricAvailable && _biometricEnabled) {
      _useBiometrics();
    }
  }

  Future<void> _submit() async {
    final pin = _pin.text.trim();
    setState(() {
      _checking = true;
      _error = null;
    });

    if (_hasPin) {
      final ok = await _security.verifyPIN(pin);
      if (!mounted) return;
      if (ok) {
        context.go('/home');
        return;
      }
      setState(() {
        _pin.clear();
        _checking = false;
        _error = 'That PIN did not match. Please try again.';
      });
      return;
    }

    final confirm = _confirmPin.text.trim();
    if (pin.length != 4 || pin != confirm) {
      setState(() {
        _checking = false;
        _error = 'Create a matching 4-digit PIN.';
      });
      return;
    }

    await _security.setPIN(pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.pinEnabledKey, true);
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _useBiometrics() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    final ok = await _security.authenticate();
    if (!mounted) return;
    if (ok) {
      context.go('/home');
      return;
    }
    setState(() {
      _checking = false;
      _error = 'Biometric unlock was not completed.';
    });
  }

  void _onKeyPress(String value) {
    if (_pin.text.length >= 4) return;
    setState(() {
      _pin.text += value;
      _error = null;
    });

    if (_pin.text.length == 4) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_pin.text.isEmpty) return;
    setState(() {
      _pin.text = _pin.text.substring(0, _pin.text.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Unlocking Mode: Premium Circular PinKeypad Screen
    if (_hasPin) {
      return Scaffold(
        appBar: const SisonkeAppBar(title: 'Lock Screen', showBackButton: false),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Safe Space Branding Header
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : SisonkeColors.mint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.spa_rounded,
                      size: 40,
                      color: isDark ? theme.colorScheme.primary : SisonkeColors.forest,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Sisonke Space',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock your safe space 🌱',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // PIN Entry Visual Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pin.text.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isFilled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.28),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Fixed height error label
              SizedBox(
                height: 24,
                child: _error != null
                    ? Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const Spacer(),

              // Circular PIN Keypad Widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: PinKeypad(
                  onKeyPress: _onKeyPress,
                  onBackspace: _onBackspace,
                  showBiometricButton: _biometricAvailable && _biometricEnabled,
                  biometricIcon: Icons.fingerprint_rounded,
                  onBiometricTrigger: _useBiometrics,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    // Passcode Setup Mode: Standard Inputs
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Setup PIN', showBackButton: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Create your PIN',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a PIN you will remember. It protects private areas on this device.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'New PIN (4 digits)',
                      prefixIcon: Icon(Icons.pin_rounded),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _checking ? null : _submit(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Confirm PIN',
                      prefixIcon: Icon(Icons.check_rounded),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _checking ? null : _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 18),
                  SisonkeButton(
                    label: _checking ? 'Saving PIN...' : 'Save PIN',
                    isLoading: _checking,
                    isEnabled: !_checking,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
