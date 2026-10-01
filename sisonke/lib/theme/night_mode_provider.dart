import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/providers/app_providers.dart';

/// Legacy night mode window (22:00–05:00)
final isNightModeProvider = Provider<bool>((ref) {
  final hour = DateTime.now().hour;
  return hour >= 22 || hour < 5;
});

/// Theme mode notifier allowing dynamic switching between System, Light, and Dark
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;

  ThemeModeNotifier(this._prefs) : super(_resolveInitialTheme(_prefs));

  static ThemeMode _resolveInitialTheme(SharedPreferences? prefs) {
    final saved = prefs?.getString('app_theme_mode');
    if (saved == 'light') return ThemeMode.light;
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'system') return ThemeMode.system;

    // Default: Check late-night window or fall back to system
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour < 5) return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final value = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.dark ? 'dark' : 'system');
    await _prefs?.setString('app_theme_mode', value);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});
