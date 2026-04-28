import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emergency_model.dart';
import '../services/emergency_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return EmergencyService(apiService, prefs);
});

// Emergency Contacts Provider
final emergencyContactsProvider = FutureProvider<EmergencyContactsResponse>((ref) async {
  final service = ref.watch(emergencyServiceProvider);
  return service.getEmergencyContacts();
});

// Emergency Toolkit Provider
final emergencyToolkitProvider = FutureProvider<EmergencyToolkit>((ref) async {
  final service = ref.watch(emergencyServiceProvider);
  return service.getEmergencyToolkit();
});

// Quick Exit Content Provider
final quickExitContentProvider = FutureProvider<QuickExitContent>((ref) async {
  final service = ref.watch(emergencyServiceProvider);
  return service.getQuickExitContent();
});

// Trusted Contacts Notifier
class TrustedContactsNotifier extends StateNotifier<AsyncValue<List<TrustedContact>>> {
  final EmergencyService _service;

  TrustedContactsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    state = const AsyncValue.loading();
    try {
      final contacts = await _service.getTrustedContacts();
      state = AsyncValue.data(contacts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addContact(TrustedContact contact) async {
    try {
      await _service.addTrustedContact(contact);
      await loadContacts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeContact(String id) async {
    try {
      await _service.removeTrustedContact(id);
      await loadContacts();
    } catch (e) {
      // Handle error
    }
  }
}

final trustedContactsProvider = StateNotifierProvider<TrustedContactsNotifier, AsyncValue<List<TrustedContact>>>((ref) {
  final service = ref.watch(emergencyServiceProvider);
  return TrustedContactsNotifier(service);
});

// Safety Plan Notifier
class SafetyPlanNotifier extends StateNotifier<AsyncValue<SafetyPlan?>> {
  final EmergencyService _service;

  SafetyPlanNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPlan();
  }

  Future<void> loadPlan() async {
    state = const AsyncValue.loading();
    try {
      final plan = await _service.getSafetyPlan();
      state = AsyncValue.data(plan);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> savePlan(SafetyPlan plan) async {
    try {
      await _service.saveSafetyPlan(plan);
      state = AsyncValue.data(plan);
    } catch (e) {
      // Handle error
    }
  }
}

final safetyPlanProvider = StateNotifierProvider<SafetyPlanNotifier, AsyncValue<SafetyPlan?>>((ref) {
  final service = ref.watch(emergencyServiceProvider);
  return SafetyPlanNotifier(service);
});
