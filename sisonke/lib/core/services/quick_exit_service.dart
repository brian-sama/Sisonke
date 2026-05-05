import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class QuickExitService {
  final SharedPreferences _prefs;

  QuickExitService(this._prefs);

  bool get isQuickExitEnabled {
    return _prefs.getBool(AppConstants.quickExitEnabledKey) ?? true;
  }

  Future<void> setQuickExitEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.quickExitEnabledKey, enabled);
  }

  List<QuickExitMethod> getQuickExitMethods() {
    final methods = <QuickExitMethod>[];

    if (_prefs.getBool('quick_exit_button') ?? true) {
      methods.add(QuickExitMethod.button);
    }

    if (_prefs.getBool('quick_exit_back_press') ?? false) {
      methods.add(QuickExitMethod.backPress);
    }

    if (_prefs.getBool('quick_exit_shake') ?? false) {
      methods.add(QuickExitMethod.shake);
    }

    if (_prefs.getBool('quick_exit_volume_keys') ?? false) {
      methods.add(QuickExitMethod.volumeKeys);
    }

    return methods;
  }

  Future<void> setQuickExitMethods({
    bool button = true,
    bool backPress = false,
    bool shake = false,
    bool volumeKeys = false,
  }) async {
    await _prefs.setBool('quick_exit_button', button);
    await _prefs.setBool('quick_exit_back_press', backPress);
    await _prefs.setBool('quick_exit_shake', shake);
    await _prefs.setBool('quick_exit_volume_keys', volumeKeys);
  }

  QuickExitDestination getQuickExitDestination() {
    final destination = _prefs.getString('quick_exit_destination') ?? 'blank';
    return QuickExitDestination.values.firstWhere(
      (dest) => dest.name == destination,
      orElse: () => QuickExitDestination.blank,
    );
  }

  Future<void> setQuickExitDestination(QuickExitDestination destination) async {
    await _prefs.setString('quick_exit_destination', destination.name);
  }

  bool shouldShowQuickExit(String routePath) {
    if (!isQuickExitEnabled) return false;

    final sensitiveRoutes = {
      '/resources',
      '/qa',
      '/qa/ask',
      '/emergency',
      '/check-in',
      '/check-in/mood',
      '/check-in/journal',
      '/talk-to-counselor',
      '/live-chat',
      '/counselor-request-status',
      '/callback-request',
      '/voice-note-request',
      '/emergency-escalation',
    };

    return sensitiveRoutes.any((route) => routePath.startsWith(route));
  }

  Future<Map<String, dynamic>> getQuickExitContent() async {
    final destination = getQuickExitDestination();

    switch (destination) {
      case QuickExitDestination.blank:
        return {'title': ''};
      case QuickExitDestination.calculator:
        return {
          'title': 'Calculator',
          'display': '0',
          'buttons': [
            ['7', '8', '9', '/'],
            ['4', '5', '6', 'x'],
            ['1', '2', '3', '-'],
            ['0', '.', '=', '+'],
          ],
        };
      case QuickExitDestination.notes:
        return {
          'title': 'My Notes',
          'notes': [
            {
              'title': 'Shopping List',
              'content': '- Milk\n- Bread\n- Eggs\n- Vegetables',
              'date': 'Today',
            },
            {
              'title': 'Meeting Notes',
              'content': 'Discussed project timeline and deliverables',
              'date': 'Yesterday',
            },
          ],
        };
    }
  }

  Future<void> logQuickExitUsage(String trigger) async {
    final usage = _prefs.getStringList('quick_exit_usage') ?? [];
    usage.add('${DateTime.now().toIso8601String()}:$trigger');

    if (usage.length > 100) {
      usage.removeRange(0, usage.length - 100);
    }

    await _prefs.setStringList('quick_exit_usage', usage);
  }

  Map<String, int> getQuickExitUsageStats() {
    final usage = _prefs.getStringList('quick_exit_usage') ?? [];
    final stats = <String, int>{};

    for (final entry in usage) {
      final parts = entry.split(':');
      if (parts.length >= 2) {
        final trigger = parts[1];
        stats[trigger] = (stats[trigger] ?? 0) + 1;
      }
    }

    return stats;
  }

  Future<void> clearUsageData() async {
    await _prefs.remove('quick_exit_usage');
  }

  Future<void> exitToPhoneHome() async {
    await SystemNavigator.pop();
  }
}

enum QuickExitMethod { button, backPress, shake, volumeKeys }

enum QuickExitDestination { blank, calculator, notes }
