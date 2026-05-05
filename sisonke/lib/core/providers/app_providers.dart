import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/bootstrap_content_service.dart';
import '../services/public_content_sync_service.dart';
import '../services/quick_exit_service.dart';
import '../services/push_notification_service.dart';

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferencesProvider must be overridden in main.dart',
  );
});

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final bootstrapContentServiceProvider = Provider<BootstrapContentService>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BootstrapContentService(prefs);
});

final publicContentSyncServiceProvider = Provider<PublicContentSyncService>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final apiService = ref.watch(apiServiceProvider);
  final bootstrapContentService = ref.watch(bootstrapContentServiceProvider);
  return PublicContentSyncService(apiService, bootstrapContentService, prefs);
});

// Quick Exit Service Provider
final quickExitServiceProvider = Provider<QuickExitService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return QuickExitService(prefs);
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return PushNotificationService(apiService);
});
