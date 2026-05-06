import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/services/security_service.dart';
import 'package:sisonke/shared/widgets/index.dart';

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
        _checking = false;
        _error = 'That PIN did not match. Please try again.';
      });
      return;
    }

    final confirm = _confirmPin.text.trim();
    if (pin.length < 4 || pin.length > 8 || pin != confirm) {
      setState(() {
        _checking = false;
        _error = 'Create a matching 4-8 digit PIN.';
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

  @override
  Widget build(BuildContext context) {
    final title = _hasPin ? 'Unlock Sisonke' : 'Create your PIN';

    return Scaffold(
      appBar: const SisonkeAppBar(title: 'App Lock', showBackButton: false),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hasPin
                            ? 'Enter your PIN to continue.'
                            : 'Choose a PIN you will remember. It protects private areas on this device.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _pin,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration: InputDecoration(
                          labelText: _hasPin ? 'PIN' : 'New PIN',
                          prefixIcon: const Icon(Icons.pin_rounded),
                          counterText: '',
                        ),
                        onSubmitted: (_) => _checking ? null : _submit(),
                      ),
                      if (!_hasPin) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPin,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          decoration: const InputDecoration(
                            labelText: 'Confirm PIN',
                            prefixIcon: Icon(Icons.check_rounded),
                            counterText: '',
                          ),
                          onSubmitted: (_) => _checking ? null : _submit(),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 18),
                      SisonkeButton(
                        label: _checking
                            ? 'Checking...'
                            : (_hasPin ? 'Unlock' : 'Save PIN'),
                        isLoading: _checking,
                        isEnabled: !_checking,
                        onPressed: _submit,
                      ),
                      if (_hasPin &&
                          _biometricEnabled &&
                          _biometricAvailable) ...[
                        const SizedBox(height: 10),
                        SisonkeButton(
                          label: 'Use biometric unlock',
                          icon: Icons.fingerprint_rounded,
                          buttonType: ButtonType.secondary,
                          isEnabled: !_checking,
                          onPressed: _useBiometrics,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
