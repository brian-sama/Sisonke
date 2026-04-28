import '../../../shared/models/resource.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ResourceService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  ResourceService(this._apiService, this._prefs);

  // Get resources with caching
  Future<ResourceListResponse> getResources({
    String? category,
    String? search,
    String? language,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(category, search, language, limit, offset);
    
    // Try to get from cache first
    if (!forceRefresh) {
      final cached = _getCachedResources(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from API
    try {
      final response = await _apiService.getResources(
        category: category,
        search: search,
        language: language,
        limit: limit,
        offset: offset,
      );

      final resourceList = ResourceListResponse.fromJson(response);
      
      // Cache the response
      await _cacheResources(cacheKey, resourceList);
      
      return resourceList;
    } catch (e) {
      // If API fails, try to return stale cache
      final cached = _getCachedResources(cacheKey);
      if (cached != null) {
        return cached;
      }
      final offline = await getOfflineResources();
      final resources = offline.map((resource) => resource.toResource()).where((resource) {
        final matchesCategory = category == null || resource.category.id == category;
        final matchesSearch = search == null ||
            resource.title.toLowerCase().contains(search.toLowerCase()) ||
            resource.description.toLowerCase().contains(search.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
      return ResourceListResponse(
        resources: resources,
        total: resources.length,
        hasMore: false,
      );
    }
  }

  // Get single resource
  Future<Resource> getResource(String id, {bool forceRefresh = false}) async {
    final cacheKey = 'resource_$id';
    
    // Try cache first
    if (!forceRefresh) {
      final cached = _getCachedResource(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final response = await _apiService.getResource(id);
      final resource = Resource.fromJson(response);
      
      // Cache the resource
      await _cacheResource(cacheKey, resource);
      
      return resource;
    } catch (e) {
      // Return stale cache if available
      final cached = _getCachedResource(cacheKey);
      if (cached != null) {
        return cached;
      }
      final offline = await getOfflineResources();
      for (final resource in offline) {
        if (resource.id == id) return resource.toResource();
      }
      rethrow;
    }
  }

  // Download resource for offline use
  Future<OfflineResource> downloadResource(String id) async {
    try {
      final response = await _apiService.downloadResource(id);
      final offlineResource = OfflineResource.fromJson(response);
      
      // Store offline resource
      await _storeOfflineResource(offlineResource);
      
      return offlineResource;
    } catch (e) {
      rethrow;
    }
  }

  // Get resource categories
  Future<List<ResourceCategory>> getResourceCategories() async {
    final cacheKey = 'resource_categories';
    
    // Try cache first
    final cached = _getCachedCategories(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final response = await _apiService.getResourceCategories();
      final categories = response
          .map((json) => ResourceCategory.fromJson(json))
          .toList();
      
      // Cache categories
      await _cacheCategories(cacheKey, categories);
      
      return categories;
    } catch (e) {
      return ResourceCategory.values;
    }
  }

  // Search resources
  Future<ResourceListResponse> searchResources(
    String query, {
    String? category,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
  }) async {
    return getResources(
      search: query,
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  // Get offline resources
  Future<List<OfflineResource>> getOfflineResources() async {
    try {
      final offlineJson = _prefs.getString(AppConstants.offlineResourcesKey);
      if (offlineJson != null) {
        final List<dynamic> offlineList = jsonDecode(offlineJson);
        return offlineList
            .map((json) => OfflineResource.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Handle corrupted cache
      await _prefs.remove(AppConstants.offlineResourcesKey);
    }
    return [];
  }

  // Remove offline resource
  Future<void> removeOfflineResource(String resourceId) async {
    try {
      final offlineResources = await getOfflineResources();
      offlineResources.removeWhere((resource) => resource.id == resourceId);
      
      final offlineJson = jsonEncode(
        offlineResources.map((r) => r.toJson()).toList(),
      );
      await _prefs.setString(AppConstants.offlineResourcesKey, offlineJson);
    } catch (e) {
      rethrow;
    }
  }

  // Check if resource is available offline
  Future<bool> isResourceAvailableOffline(String resourceId) async {
    final offlineResources = await getOfflineResources();
    return offlineResources.any((resource) => resource.id == resourceId);
  }

  // Get cached resources
  ResourceListResponse? _getCachedResources(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        // Check if cache is still valid
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          return ResourceListResponse.fromJson(cachedData['data']);
        }
        
        // Remove expired cache
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  // Cache resources
  Future<void> _cacheResources(String cacheKey, ResourceListResponse resources) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': resources.toJson(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Get cached resource
  Resource? _getCachedResource(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          return Resource.fromJson(cachedData['data']);
        }
        
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  // Cache resource
  Future<void> _cacheResource(String cacheKey, Resource resource) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': resource.toJson(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Get cached categories
  List<ResourceCategory>? _getCachedCategories(String cacheKey) {
    try {
      final cachedJson = _prefs.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            AppConstants.cacheExpiration.inMilliseconds) {
          final List<dynamic> categoriesList = cachedData['data'];
          return categoriesList
              .map((json) => ResourceCategory.fromJson(json))
              .toList();
        }
        
        _prefs.remove(cacheKey);
      }
    } catch (e) {
      _prefs.remove(cacheKey);
    }
    return null;
  }

  // Cache categories
  Future<void> _cacheCategories(String cacheKey, List<ResourceCategory> categories) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': categories.map((c) => c.toJson()).toList(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Store offline resource
  Future<void> _storeOfflineResource(OfflineResource resource) async {
    try {
      final offlineResources = await getOfflineResources();
      
      // Remove existing resource with same ID if present
      offlineResources.removeWhere((r) => r.id == resource.id);
      
      // Add new resource
      offlineResources.add(resource);
      
      final offlineJson = jsonEncode(
        offlineResources.map((r) => r.toJson()).toList(),
      );
      await _prefs.setString(AppConstants.offlineResourcesKey, offlineJson);
    } catch (e) {
      rethrow;
    }
  }

  // Generate cache key
  String _generateCacheKey(
    String? category,
    String? search,
    String? language,
    int limit,
    int offset,
  ) {
    final parts = ['resources'];
    if (category != null) parts.add(category);
    if (search != null) parts.add(search);
    if (language != null) parts.add(language);
    parts.add(limit.toString());
    parts.add(offset.toString());
    return parts.join('_');
  }

  // Clear cache
  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('resources_') || key.startsWith('resource_')) {
        await _prefs.remove(key);
      }
    }
  }
}
