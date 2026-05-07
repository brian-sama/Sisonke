import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/services/security_service.dart';
import 'package:sisonke/shared/widgets/pin_keypad.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class PrivacyGuard extends StatefulWidget {
  final Widget child;

  const PrivacyGuard({super.key, required this.child});

  @override
  State<PrivacyGuard> createState() => _PrivacyGuardState();
}

class _PrivacyGuardState extends State<PrivacyGuard> {
  late final AppLifecycleListener _lifecycleListener;
  final SecurityService _securityService = SecurityService();
  
  bool _isShielded = false;
  bool _isLocked = false;
  DateTime? _backgroundedTime;
  String _enteredPin = '';
  String? _errorMessage;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _lifecycleListener = AppLifecycleListener(
      onHide: _onAppBackgrounded,
      onPause: _onAppBackgrounded,
      onShow: _onAppForegrounded,
      onResume: _onAppForegrounded,
    );
  }

  Future<void> _checkBiometrics() async {
    try {
      final available = await _securityService.isBiometricAvailable();
      if (mounted) {
        setState(() {
          _biometricAvailable = available;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _biometricEnabled = prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
    } catch (_) {}
  }

  void _onAppBackgrounded() {
    _backgroundedTime = DateTime.now();
    setState(() {
      _isShielded = true;
    });
  }

  Future<void> _onAppForegrounded() async {
    if (_backgroundedTime == null) return;

    final now = DateTime.now();
    final elapsedSeconds = now.difference(_backgroundedTime!).inSeconds;
    _backgroundedTime = null;

    final prefs = await SharedPreferences.getInstance();
    final pinEnabled = prefs.getBool(AppConstants.pinEnabledKey) ?? false;
    final hasPin = await _securityService.hasPIN();

    if (!pinEnabled || !hasPin) {
      // PIN lock not active, remove shield instantly
      setState(() {
        _isShielded = false;
        _isLocked = false;
      });
      return;
    }

    // Load auto-lock timeout duration (default: 30 seconds if not customized)
    final autoLockDurationSeconds = prefs.getInt('auto_lock_duration_seconds') ?? 30;

    if (autoLockDurationSeconds == -1) {
      // Lock is set to "Never", remove shield instantly
      setState(() {
        _isShielded = false;
        _isLocked = false;
      });
      return;
    }

    if (elapsedSeconds >= autoLockDurationSeconds) {
      // Lock the app and load biometric details
      await _loadSettings();
      setState(() {
        _isLocked = true;
        _enteredPin = '';
        _errorMessage = null;
      });
      
      // Automatically trigger biometric authentication if enabled
      if (_biometricAvailable && _biometricEnabled) {
        _triggerBiometricAuth();
      }
    } else {
      // Under timeout: resume session instantly without lockout
      setState(() {
        _isShielded = false;
      });
    }
  }

  Future<void> _triggerBiometricAuth() async {
    final success = await _securityService.authenticate();
    if (success && mounted) {
      setState(() {
        _isShielded = false;
        _isLocked = false;
        _enteredPin = '';
        _errorMessage = null;
      });
    }
  }

  void _handleKeyPress(String number) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += number;
      _errorMessage = null;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    final success = await _securityService.verifyPIN(_enteredPin);
    if (!mounted) return;

    if (success) {
      setState(() {
        _isShielded = false;
        _isLocked = false;
        _enteredPin = '';
        _errorMessage = null;
      });
    } else {
      setState(() {
        _enteredPin = '';
        _errorMessage = 'Incorrect PIN. Please try again gently.';
      });
    }
  }

  void _triggerEmergencyBypass() {
    // Dismiss lock state completely to allow direct emergency routing
    setState(() {
      _isShielded = false;
      _isLocked = false;
      _enteredPin = '';
      _errorMessage = null;
    });
    // Route to emergency screen instantly
    context.go('/emergency');
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the app is neither background shielded nor PIN locked, render the application normally
    if (!_isShielded && !_isLocked) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          // Underlay app content
          widget.child,

          // Full screen blur overlay to block screenshots and recents preview
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: isDark 
                    ? const Color(0xFF1E2221).withValues(alpha: 0.88)
                    : SisonkeColors.cream.withValues(alpha: 0.92),
              ),
            ),
          ),

          // If locked, overlay the premium security PIN keypad
          if (_isLocked)
            Positioned.fill(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Column(
                    children: [
                      // Emergency Help Header Bypass Row
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(color: Colors.redAccent, width: 1.2),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: const Icon(Icons.emergency_rounded, size: 20),
                            label: const Text(
                              'Emergency Help',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _triggerEmergencyBypass,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Calm Lock Branding
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

                      // PIN entry visual dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _enteredPin.length;
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

                      // Error message container (fixed height to prevent layout shifts)
                      SizedBox(
                        height: 24,
                        child: _errorMessage != null
                            ? Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const Spacer(),

                      // Circular PIN Keypad
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: PinKeypad(
                          onKeyPress: _handleKeyPress,
                          onBackspace: _handleBackspace,
                          showBiometricButton: _biometricAvailable && _biometricEnabled,
                          biometricIcon: theme.brightness == Brightness.dark
                              ? Icons.fingerprint_rounded
                              : Icons.fingerprint_rounded,
                          onBiometricTrigger: _triggerBiometricAuth,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
