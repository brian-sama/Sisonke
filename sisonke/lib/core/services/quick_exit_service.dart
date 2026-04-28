import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class QuickExitService {
  final SharedPreferences _prefs;

  QuickExitService(this._prefs);

  // Check if Quick Exit is enabled
  bool get isQuickExitEnabled {
    return _prefs.getBool(AppConstants.quickExitEnabledKey) ?? true;
  }

  // Enable/disable Quick Exit
  Future<void> setQuickExitEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.quickExitEnabledKey, enabled);
  }

  // Get Quick Exit trigger methods
  List<QuickExitMethod> getQuickExitMethods() {
    final methods = <QuickExitMethod>[];
    
    if (_prefs.getBool('quick_exit_button') ?? true) {
      methods.add(QuickExitMethod.button);
    }
    
    if (_prefs.getBool('quick_exit_back_press') ?? true) {
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

  // Set Quick Exit methods
  Future<void> setQuickExitMethods({
    bool button = true,
    bool backPress = true,
    bool shake = false,
    bool volumeKeys = false,
  }) async {
    await _prefs.setBool('quick_exit_button', button);
    await _prefs.setBool('quick_exit_back_press', backPress);
    await _prefs.setBool('quick_exit_shake', shake);
    await _prefs.setBool('quick_exit_volume_keys', volumeKeys);
  }

  // Get Quick Exit destination
  QuickExitDestination getQuickExitDestination() {
    final destination = _prefs.getString('quick_exit_destination') ?? 'weather';
    return QuickExitDestination.values.firstWhere(
      (dest) => dest.name == destination,
      orElse: () => QuickExitDestination.weather,
    );
  }

  // Set Quick Exit destination
  Future<void> setQuickExitDestination(QuickExitDestination destination) async {
    await _prefs.setString('quick_exit_destination', destination.name);
  }

  // Check if screen should have Quick Exit
  bool shouldShowQuickExit(String routePath) {
    if (!isQuickExitEnabled) return false;
    
    // Define sensitive routes that should always have Quick Exit
    final sensitiveRoutes = {
      '/resources',
      '/qa',
      '/qa/ask',
      '/emergency',
      '/check-in',
      '/check-in/mood',
      '/check-in/journal',
    };
    
    // Check if current route is sensitive
    return sensitiveRoutes.any((route) => routePath.startsWith(route));
  }

  // Get Quick Exit content
  Future<Map<String, dynamic>> getQuickExitContent() async {
    final destination = getQuickExitDestination();
    
    switch (destination) {
      case QuickExitDestination.weather:
        return {
          'title': 'Weather Today',
          'temperature': '24°C',
          'condition': 'Partly Cloudy',
          'forecast': 'Pleasant weather expected throughout the day',
          'location': 'Harare, Zimbabwe',
          'hourly': [
            {'time': '9:00 AM', 'temp': '22°C', 'condition': 'Sunny'},
            {'time': '12:00 PM', 'temp': '26°C', 'condition': 'Partly Cloudy'},
            {'time': '3:00 PM', 'temp': '25°C', 'condition': 'Cloudy'},
            {'time': '6:00 PM', 'temp': '21°C', 'condition': 'Clear'},
          ],
        };
      case QuickExitDestination.news:
        return {
          'title': 'Latest News',
          'headline': 'Local Community Updates',
          'articles': [
            {
              'title': 'Community Health Initiative Launch',
              'summary': 'New wellness program announced for local residents',
              'time': '2 hours ago',
            },
            {
              'title': 'Weather Forecast for the Week',
              'summary': 'Mild temperatures expected with occasional showers',
              'time': '4 hours ago',
            },
            {
              'title': 'Local Sports Results',
              'summary': 'Weekend games wrap up with exciting finishes',
              'time': '6 hours ago',
            },
          ],
        };
      case QuickExitDestination.calculator:
        return {
          'title': 'Calculator',
          'display': '0',
          'buttons': [
            ['7', '8', '9', '÷'],
            ['4', '5', '6', '×'],
            ['1', '2', '3', '−'],
            ['0', '.', '=', '+'],
          ],
        };
      case QuickExitDestination.notes:
        return {
          'title': 'My Notes',
          'notes': [
            {
              'title': 'Shopping List',
              'content': '• Milk\n• Bread\n• Eggs\n• Vegetables',
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

  // Log Quick Exit usage (for analytics, privacy-safe)
  Future<void> logQuickExitUsage(String trigger) async {
    final usage = _prefs.getStringList('quick_exit_usage') ?? [];
    usage.add('${DateTime.now().toIso8601String()}:$trigger');
    
    // Keep only last 100 entries
    if (usage.length > 100) {
      usage.removeRange(0, usage.length - 100);
    }
    
    await _prefs.setStringList('quick_exit_usage', usage);
  }

  // Get Quick Exit usage statistics
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

  // Clear Quick Exit usage data
  Future<void> clearUsageData() async {
    await _prefs.remove('quick_exit_usage');
  }
}

enum QuickExitMethod {
  button,
  backPress,
  shake,
  volumeKeys,
}

enum QuickExitDestination {
  weather,
  news,
  calculator,
  notes,
}
