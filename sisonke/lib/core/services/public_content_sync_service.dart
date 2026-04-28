import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'api_service.dart';
import 'bootstrap_content_service.dart';

class PublicContentSyncService {
  final ApiService _apiService;
  final BootstrapContentService _bootstrapContentService;
  final SharedPreferences _prefs;

  PublicContentSyncService(
    this._apiService,
    this._bootstrapContentService,
    this._prefs,
  );

  Future<void> sync() async {
    final lastSync = _prefs.getString(AppConstants.lastSyncKey);
    final response = await _apiService.syncPublicContent(since: lastSync);
    final serverTime = response['serverTime'] as String? ?? DateTime.now().toIso8601String();

    final resources = (response['resources'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final contacts = (response['emergencyContacts'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    await _bootstrapContentService.replacePublicContent(
      resources: resources.isEmpty ? null : resources,
      emergencyContacts: contacts.isEmpty ? null : contacts,
      syncedAt: serverTime,
    );

    await _apiService.recordAnalyticsEvent(event: 'sync_completed');
  }
}
