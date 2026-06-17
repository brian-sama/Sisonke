import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _pinKey = 'app_pin';
  static const String _pinSaltKey = 'app_pin_salt';

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

  // Generate a 32-byte cryptographically random hex salt.
  String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPINWithSalt(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  Future<void> setPIN(String pin) async {
    final salt = _generateSalt();
    final hashed = _hashPINWithSalt(pin, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinKey, value: hashed);
  }

  Future<void> clearPIN() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinSaltKey);
  }

  Future<bool> verifyPIN(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;

    final salt = await _storage.read(key: _pinSaltKey);

    if (salt != null) {
      // Current format: salted SHA-256
      return storedHash == _hashPINWithSalt(pin, salt);
    }

    // Legacy: unsalted SHA-256 — upgrade on successful match
    final unsaltedHash = sha256.convert(utf8.encode(pin)).toString();
    if (storedHash == unsaltedHash) {
      await setPIN(pin); // re-store with salt
      return true;
    }

    // Legacy: plaintext PIN stored directly
    if (storedHash == pin) {
      await setPIN(pin); // re-store hashed + salted
      return true;
    }

    return false;
  }

  Future<bool> hasPIN() async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin != null;
  }

  // FLAG_SECURE is applied unconditionally in MainActivity.onCreate(), which
  // blocks screenshots and hides the app preview in the Android recents screen
  // across every route. These methods are intentional no-ops — removing the
  // global flag would require a native-channel toggle, which is not needed
  // because Sisonke should always prevent screen capture.
  Future<void> enableScreenshotProtection() async {}

  Future<void> disableScreenshotProtection() async {}

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
