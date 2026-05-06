import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _pinKey = 'app_pin';

  Future<bool> isBiometricAvailable() async {
    if (!_supportsBiometricsOnCurrentPlatform) return false;
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    if (!_supportsBiometricsOnCurrentPlatform) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your private data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> setPIN(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<void> clearPIN() async {
    await _storage.delete(key: _pinKey);
  }

  Future<bool> verifyPIN(String pin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == pin;
  }

  Future<bool> hasPIN() async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin != null;
  }

  Future<void> enableScreenshotProtection() async {
    // TODO: Re-enable Android FLAG_SECURE with a maintained plugin or native channel.
  }

  Future<void> disableScreenshotProtection() async {
    // TODO: Re-enable Android FLAG_SECURE with a maintained plugin or native channel.
  }

  bool get _supportsBiometricsOnCurrentPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      TargetPlatform.linux || TargetPlatform.fuchsia => false,
    };
  }
}
