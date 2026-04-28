import '../models/emergency_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmergencyService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  EmergencyService(this._apiService, this._prefs);

  // Get emergency contacts with caching
  Future<EmergencyContactsResponse> getEmergencyContacts({bool forceRefresh = false}) async {
    const cacheKey = 'emergency_contacts';
    
    // Try to get from cache first
    if (!forceRefresh) {
      final cached = _getCachedContacts(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from API
    try {
      final response = await _apiService.getEmergencyContacts();
      final contactsResponse = EmergencyContactsResponse.fromJson(response);
      
      // Cache the response
      await _cacheContacts(cacheKey, contactsResponse);
      
      return contactsResponse;
    } catch (e) {
      // If API fails, try to return stale cache
      final cached = _getCachedContacts(cacheKey);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  // Get emergency toolkit with caching
  Future<EmergencyToolkit> getEmergencyToolkit({bool forceRefresh = false}) async {
    const cacheKey = 'emergency_toolkit';
    
    // Try to get from cache first
    if (!forceRefresh) {
      final cached = _getCachedToolkit(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from API
    try {
      final response = await _apiService.getEmergencyToolkit();
      final toolkit = EmergencyToolkit.fromJson(response);
      
      // Cache the response
      await _cacheToolkit(cacheKey, toolkit);
      
      return toolkit;
    } catch (e) {
      // If API fails, try to return stale cache
      final cached = _getCachedToolkit(cacheKey);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  // Get quick exit content with caching
  Future<QuickExitContent> getQuickExitContent({bool forceRefresh = false}) async {
    const cacheKey = 'quick_exit_content';
    
    // Try to get from cache first
    if (!forceRefresh) {
      final cached = _getCachedQuickExit(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from API
    try {
      final response = await _apiService.getQuickExitContent();
      final quickExit = QuickExitContent.fromJson(response);
      
      // Cache the response
      await _cacheQuickExit(cacheKey, quickExit);
      
      return quickExit;
    } catch (e) {
      // If API fails, try to return stale cache
      final cached = _getCachedQuickExit(cacheKey);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  // Get contacts by category
  Future<List<EmergencyContact>> getContactsByCategory(String category) async {
    final contactsResponse = await getEmergencyContacts();
    return contactsResponse.contacts[category] ?? [];
  }

  // Get Zimbabwe emergency numbers (fallback)
  List<EmergencyContact> getZimbabweEmergencyNumbers() {
    return [
      EmergencyContact(
        id: 'lifeline',
        name: 'Lifeline Zimbabwe',
        phoneNumber: AppConstants.zimbabweEmergencyNumbers['lifeline']!,
        category: 'crisis',
        description: '24/7 crisis support helpline',
        isActive: true,
        country: 'ZW',
        createdAt: DateTime.now(),
      ),
      EmergencyContact(
        id: 'alac',
        name: 'ALAC Zimbabwe',
        phoneNumber: AppConstants.zimbabweEmergencyNumbers['alac']!,
        category: 'srhr',
        description: 'Legal aid and counseling',
        isActive: true,
        country: 'ZW',
        createdAt: DateTime.now(),
      ),
      EmergencyContact(
        id: 'mental_welfare',
        name: 'Mental Welfare',
        phoneNumber: AppConstants.zimbabweEmergencyNumbers['mental_welfare']!,
        category: 'mental-health',
        description: 'Mental health support services',
        isActive: true,
        country: 'ZW',
        createdAt: DateTime.now(),
      ),
      EmergencyContact(
        id: 'srhr_services',
        name: 'SRHR Services',
        phoneNumber: AppConstants.zimbabweEmergencyNumbers['srhr_services']!,
        category: 'srhr',
        description: 'Sexual and reproductive health services',
        isActive: true,
        country: 'ZW',
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Check if user has trusted contacts
  Future<List<TrustedContact>> getTrustedContacts() async {
    try {
      final contactsJson = _prefs.getString('trusted_contacts');
      if (contactsJson != null) {
        final List<dynamic> contactsList = jsonDecode(contactsJson);
        return contactsList
            .map((json) => TrustedContact.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Handle corrupted cache
      await _prefs.remove('trusted_contacts');
    }
    return [];
  }

  // Add trusted contact
  Future<void> addTrustedContact(TrustedContact contact) async {
    try {
      final contacts = await getTrustedContacts();
      contacts.add(contact);
      
      final contactsJson = jsonEncode(
        contacts.map((c) => c.toJson()).toList(),
      );
      await _prefs.setString('trusted_contacts', contactsJson);
    } catch (e) {
      rethrow;
    }
  }

  // Remove trusted contact
  Future<void> removeTrustedContact(String contactId) async {
    try {
      final contacts = await getTrustedContacts();
      contacts.removeWhere((contact) => contact.id == contactId);
      
      final contactsJson = jsonEncode(
        contacts.map((c) => c.toJson()).toList(),
      );
      await _prefs.setString('trusted_contacts', contactsJson);
    } catch (e) {
      rethrow;
    }
  }

  // Get safety plan
  Future<SafetyPlan?> getSafetyPlan() async {
    try {
      final planJson = _prefs.getString('safety_plan');
      if (planJson != null) {
        return SafetyPlan.fromJson(jsonDecode(planJson));
      }
    } catch (e) {
      // Handle corrupted cache
      await _prefs.remove('safety_plan');
    }
    return null;
  }

  // Save safety plan
  Future<void> saveSafetyPlan(SafetyPlan safetyPlan) async {
    try {
      final planJson = jsonEncode(safetyPlan.toJson());
      await _prefs.setString('safety_plan', planJson);
    } catch (e) {
      rethrow;
    }
  }

  // Private cache methods
  EmergencyContactsResponse? _getCachedContacts(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        // Check if cache is still valid (emergency contacts should be cached longer)
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            Duration(hours: 24).inMilliseconds) {
          return EmergencyContactsResponse.fromJson(cachedData['data']);
        }
        
        // Remove expired cache
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  Future<void> _cacheContacts(String cacheKey, EmergencyContactsResponse contacts) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': contacts.toJson(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  EmergencyToolkit? _getCachedToolkit(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          return EmergencyToolkit.fromJson(cachedData['data']);
        }
        
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  Future<void> _cacheToolkit(String cacheKey, EmergencyToolkit toolkit) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': toolkit.toJson(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  QuickExitContent? _getCachedQuickExit(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          return QuickExitContent.fromJson(cachedData['data']);
        }
        
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  Future<void> _cacheQuickExit(String cacheKey, QuickExitContent quickExit) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': quickExit.toJson(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    await _prefs.remove('emergency_contacts');
    await _prefs.remove('emergency_toolkit');
    await _prefs.remove('quick_exit_content');
  }
}
