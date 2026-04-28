import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/resource.dart';
import '../services/resource_service.dart';
import '../../../core/providers/app_providers.dart';

// Providers
final resourceServiceProvider = Provider<ResourceService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ResourceService(apiService, prefs);
});

// Resource List State
class ResourceListState {
  final List<Resource> resources;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentOffset;

  const ResourceListState({
    this.resources = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentOffset = 0,
  });

  ResourceListState copyWith({
    List<Resource>? resources,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentOffset,
  }) {
    return ResourceListState(
      resources: resources ?? this.resources,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

// Resource List Notifier
class ResourceListNotifier extends StateNotifier<ResourceListState> {
  final ResourceService _resourceService;
  String? _currentCategory;
  String? _currentSearch;
  String? _currentLanguage;

  ResourceListNotifier(this._resourceService) : super(const ResourceListState());

  Future<void> loadResources({
    String? category,
    String? search,
    String? language,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentCategory = category;
      _currentSearch = search;
      _currentLanguage = language;
      state = state.copyWith(
        resources: [],
        isLoading: true,
        error: null,
        hasMore: true,
        currentOffset: 0,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    }

    try {
      final response = await _resourceService.getResources(
        category: _currentCategory ?? category,
        search: _currentSearch ?? search,
        language: _currentLanguage ?? language,
        offset: refresh ? 0 : state.currentOffset,
      );

      final newResources = refresh 
          ? response.resources 
          : [...state.resources, ...response.resources];

      state = state.copyWith(
        resources: newResources,
        isLoading: false,
        isLoadingMore: false,
        error: null,
        hasMore: response.hasMore,
        currentOffset: refresh ? response.resources.length : state.currentOffset + response.resources.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreResources() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _resourceService.getResources(
        category: _currentCategory,
        search: _currentSearch,
        language: _currentLanguage,
        offset: state.currentOffset,
      );

      state = state.copyWith(
        resources: [...state.resources, ...response.resources],
        isLoadingMore: false,
        hasMore: response.hasMore,
        currentOffset: state.currentOffset + response.resources.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchResources(String query, {String? category}) async {
    _currentSearch = query;
    _currentCategory = category;
    await loadResources(refresh: true);
  }

  Future<void> filterByCategory(String? category) async {
    _currentCategory = category;
    await loadResources(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ResourceListState();
    _currentCategory = null;
    _currentSearch = null;
    _currentLanguage = null;
  }
}

// Single Resource State
class ResourceState {
  final Resource? resource;
  final bool isLoading;
  final String? error;
  final bool isBookmarked;

  const ResourceState({
    this.resource,
    this.isLoading = false,
    this.error,
    this.isBookmarked = false,
  });

  ResourceState copyWith({
    Resource? resource,
    bool? isLoading,
    String? error,
    bool? isBookmarked,
  }) {
    return ResourceState(
      resource: resource ?? this.resource,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

// Single Resource Notifier
class ResourceNotifier extends StateNotifier<ResourceState> {
  final ResourceService _resourceService;

  ResourceNotifier(this._resourceService) : super(const ResourceState());

  Future<void> loadResource(String id) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final resource = await _resourceService.getResource(id);
      final isBookmarked = await _resourceService.isResourceAvailableOffline(id);
      
      state = state.copyWith(
        resource: resource,
        isLoading: false,
        isBookmarked: isBookmarked,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> downloadForOffline(String resourceId) async {
    try {
      await _resourceService.downloadResource(resourceId);
      state = state.copyWith(isBookmarked: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromOffline(String resourceId) async {
    try {
      await _resourceService.removeOfflineResource(resourceId);
      state = state.copyWith(isBookmarked: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ResourceState();
  }
}

// Categories State
class CategoriesState {
  final List<ResourceCategory> categories;
  final bool isLoading;
  final String? error;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriesState copyWith({
    List<ResourceCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Categories Notifier
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final ResourceService _resourceService;

  CategoriesNotifier(this._resourceService) : super(const CategoriesState());

  Future<void> loadCategories() async {
    if (state.isLoading || state.categories.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _resourceService.getResourceCategories();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Offline Resources State
class OfflineResourcesState {
  final List<OfflineResource> resources;
  final bool isLoading;
  final String? error;

  const OfflineResourcesState({
    this.resources = const [],
    this.isLoading = false,
    this.error,
  });

  OfflineResourcesState copyWith({
    List<OfflineResource>? resources,
    bool? isLoading,
    String? error,
  }) {
    return OfflineResourcesState(
      resources: resources ?? this.resources,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Offline Resources Notifier
class OfflineResourcesNotifier extends StateNotifier<OfflineResourcesState> {
  final ResourceService _resourceService;

  OfflineResourcesNotifier(this._resourceService) : super(const OfflineResourcesState());

  Future<void> loadOfflineResources() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final resources = await _resourceService.getOfflineResources();
      state = state.copyWith(
        resources: resources,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeFromOffline(String resourceId) async {
    try {
      await _resourceService.removeOfflineResource(resourceId);
      final updatedResources = state.resources
          .where((resource) => resource.id != resourceId)
          .toList();
      state = state.copyWith(resources: updatedResources);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider declarations
final resourceListProvider = StateNotifierProvider<ResourceListNotifier, ResourceListState>((ref) {
  final resourceService = ref.watch(resourceServiceProvider);
  return ResourceListNotifier(resourceService);
});

final resourceProvider = StateNotifierProvider.family<ResourceNotifier, ResourceState, String>((ref, resourceId) {
  final resourceService = ref.watch(resourceServiceProvider);
  return ResourceNotifier(resourceService);
});

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final resourceService = ref.watch(resourceServiceProvider);
  return CategoriesNotifier(resourceService);
});

final offlineResourcesProvider = StateNotifierProvider<OfflineResourcesNotifier, OfflineResourcesState>((ref) {
  final resourceService = ref.watch(resourceServiceProvider);
  return OfflineResourcesNotifier(resourceService);
});

// Search provider
final searchResultsProvider = StateNotifierProvider<ResourceListNotifier, ResourceListState>((ref) {
  final resourceService = ref.watch(resourceServiceProvider);
  return ResourceListNotifier(resourceService);
});
