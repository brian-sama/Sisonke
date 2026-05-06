import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:sisonke/shared/models/mood.dart';

class WidgetSnapshot {
  final String mood;
  final String companionText;
  final int gratitudeStars;

  const WidgetSnapshot({
    required this.mood,
    required this.companionText,
    required this.gratitudeStars,
  });
}

/// Synchronizes privacy-safe companion state with native home screen widgets.
class WidgetService {
  static const String _groupId = 'group.zw.co.mmpzmne.sisonke';
  static const String _androidWidgetName = 'SisonkeHomeWidgetProvider';
  static const String defaultCompanionText =
      'Take a slow, comforting breath. I am nearby.';

  static WidgetSnapshot snapshotForMood({
    required MoodType mood,
    required int gratitudeStars,
  }) {
    switch (mood) {
      case MoodType.great:
        return WidgetSnapshot(
          mood: 'sunlight',
          companionText: 'Proud of you for showing up today.',
          gratitudeStars: gratitudeStars,
        );
      case MoodType.okay:
        return WidgetSnapshot(
          mood: 'breeze',
          companionText: 'Take things one step at a time.',
          gratitudeStars: gratitudeStars,
        );
      case MoodType.low:
        return WidgetSnapshot(
          mood: 'rain',
          companionText: 'You are not alone. Take this gently.',
          gratitudeStars: gratitudeStars,
        );
      case MoodType.overwhelmed:
        return WidgetSnapshot(
          mood: 'cloud',
          companionText: 'It is okay to pause and breathe.',
          gratitudeStars: gratitudeStars,
        );
      case MoodType.anxious:
      case MoodType.angry:
        return WidgetSnapshot(
          mood: 'storm',
          companionText: 'Focus on one slow breath right now.',
          gratitudeStars: gratitudeStars,
        );
    }
  }

  /// Initialize the iOS App Group shared container.
  static Future<void> setup() async {
    try {
      await HomeWidget.setAppGroupId(_groupId);
    } catch (e) {
      if (kDebugMode) debugPrint('WidgetService setup skipped: $e');
    }
  }

  static Future<void> syncMoodAndCompanion({
    required String mood,
    required String companionText,
    required int gratitudeStars,
  }) async {
    try {
      final safeText = companionText.trim().isEmpty
          ? defaultCompanionText
          : companionText.trim();
      final safeStars = gratitudeStars < 0 ? 0 : gratitudeStars;

      await HomeWidget.saveWidgetData<String>('mood', mood);
      await HomeWidget.saveWidgetData<String>('companion_text', safeText);
      await HomeWidget.saveWidgetData<int>('gratitude_stars', safeStars);

      await HomeWidget.updateWidget(
        iOSName: 'SisonkeWidget',
        androidName: _androidWidgetName,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('WidgetService sync skipped: $e');
    }
  }

  static Future<void> syncSnapshot(WidgetSnapshot snapshot) {
    return syncMoodAndCompanion(
      mood: snapshot.mood,
      companionText: snapshot.companionText,
      gratitudeStars: snapshot.gratitudeStars,
    );
  }
}
