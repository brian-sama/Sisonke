import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for app theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

enum ThemeMode {
  light('Light'),
  dark('Dark'),
  system('System');

  final String label;
  const ThemeMode(this.label);
}

/// Provider for app language
final languageProvider = StateProvider<String>((ref) => 'en');

/// Provider for text size
final textSizeProvider = StateProvider<TextSize>((ref) => TextSize.medium);

enum TextSize {
  small('Small', 14),
  medium('Medium', 16),
  large('Large', 18),
  extraLarge('Extra Large', 20);

  final String label;
  final double size;
  const TextSize(this.label, this.size);
}

/// Provider for notification settings
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

/// Provider for app lock enabled
final appLockEnabledProvider = StateProvider<bool>((ref) => false);

/// Provider for app PIN (would be encrypted in real app)
final appPINProvider = StateProvider<String?>((ref) => null);

/// Provider for biometric enabled
final biometricEnabledProvider = StateProvider<bool>((ref) => false);

/// Provider for offline mode
final offlineModeProvider = StateProvider<bool>((ref) => false);

