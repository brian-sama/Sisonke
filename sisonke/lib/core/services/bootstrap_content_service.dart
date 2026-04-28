import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class BootstrapContentService {
  static const _assetPath = 'assets/bootstrap/emergency_seed_v1.json';
  static const _bootstrapVersionKey = 'bootstrap_content_version';
  static const _emergencyContactsKey = 'offline_emergency_contacts';

  final SharedPreferences _prefs;

  BootstrapContentService(this._prefs);

  Future<void> ensureSeeded() async {
    final seedJson = await rootBundle.loadString(_assetPath);
    final seed = jsonDecode(seedJson) as Map<String, dynamic>;
    final version = seed['version'] as int? ?? 1;
    final installedVersion = _prefs.getInt(_bootstrapVersionKey) ?? 0;

    if (installedVersion >= version) return;

    final resources = (seed['resources'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final contacts = (seed['emergencyContacts'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    await _prefs.setString(
      AppConstants.offlineResourcesKey,
      jsonEncode(resources),
    );
    await _prefs.setString(
      _emergencyContactsKey,
      jsonEncode(contacts),
    );
    await _prefs.setInt(_bootstrapVersionKey, version);
  }

  List<Map<String, dynamic>> getEmergencyContacts() {
    final json = _prefs.getString(_emergencyContactsKey);
    if (json == null) return const [];
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> replacePublicContent({
    List<Map<String, dynamic>>? resources,
    List<Map<String, dynamic>>? emergencyContacts,
    required String syncedAt,
  }) async {
    if (resources != null) {
      await _prefs.setString(AppConstants.offlineResourcesKey, jsonEncode(resources));
    }
    if (emergencyContacts != null) {
      await _prefs.setString(_emergencyContactsKey, jsonEncode(emergencyContacts));
    }
    await _prefs.setString(AppConstants.lastSyncKey, syncedAt);
  }
}
