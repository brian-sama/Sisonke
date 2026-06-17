import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when the current local time is in the 2am window (22:00–05:00).
/// Consumed by MyApp to force dark mode during late-night sessions.
final isNightModeProvider = Provider<bool>((ref) {
  final hour = DateTime.now().hour;
  return hour >= 22 || hour < 5;
});
