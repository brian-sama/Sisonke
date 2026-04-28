import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/models/index.dart';

/// Provider for all resources
final resourcesProvider = StateProvider<List<Resource>>((ref) => []);

/// Provider for filtered resources
final filteredResourcesProvider = StateProvider<List<Resource>>((ref) {
  final resources = ref.watch(resourcesProvider);
  final selectedCategory = ref.watch(resourceCategoryFilterProvider);

  if (selectedCategory == null) {
    return resources;
  }

  return resources
      .where((r) => r.category == selectedCategory)
      .toList();
});

/// Provider for resource search query
final resourceSearchProvider = StateProvider<String>((ref) => '');

/// Provider for resource category filter
final resourceCategoryFilterProvider =
    StateProvider<ResourceCategory?>((ref) => null);

/// Provider for saved resources
final savedResourcesProvider = StateProvider<List<String>>((ref) => []);

/// Provider for resource detail
final resourceDetailProvider =
    StateProvider.family<Resource?, String>((ref, resourceId) {
  final resources = ref.watch(resourcesProvider);
  try {
    return resources.firstWhere((r) => r.id == resourceId);
  } catch (e) {
    return null;
  }
});

