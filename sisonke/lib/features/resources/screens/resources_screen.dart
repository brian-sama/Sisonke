import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/resource_provider.dart';
import '../widgets/resource_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/search_bar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/quick_exit_wrapper.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    ref.read(categoriesProvider.notifier).loadCategories();
    ref.read(resourceListProvider.notifier).loadResources();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(resourceListProvider.notifier).loadMoreResources();
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      ref.read(resourceListProvider.notifier).loadResources(refresh: true);
    }
  }

  void _onSearchSubmitted(String query) {
    ref.read(resourceListProvider.notifier).searchResources(query);
  }

  void _onCategorySelected(String? category) {
    ref.read(resourceListProvider.notifier).filterByCategory(category);
  }

  void _onRefresh() {
    ref.read(resourceListProvider.notifier).loadResources(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final resourceListState = ref.watch(resourceListProvider);
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: QuickExitWrapper(
        currentRoute: '/resources',
        options: QuickExitPresets.sensitive,
        child: RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: ResourceSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
            ),

            // Category Filter
            if (categoriesState.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMedium,
                  ),
                  child: CategoryFilter(
                    categories: categoriesState.categories,
                    onCategorySelected: _onCategorySelected,
                  ),
                ),
              ),

            // Error Message
            if (resourceListState.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingMedium),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: AppConstants.spacingSmall),
                          Expanded(
                            child: Text(
                              resourceListState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(resourceListProvider.notifier).clearError();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Loading Indicator
            if (resourceListState.isLoading && resourceListState.resources.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            // Resources List
            if (resourceListState.resources.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == resourceListState.resources.length) {
                        // Loading More Indicator
                        return resourceListState.isLoadingMore
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppConstants.spacingMedium),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final resource = resourceListState.resources[index];
                      return ResourceCard(
                        resource: resource,
                        onTap: () {
                          context.push('/resources/${resource.id}');
                        },
                      );
                    },
                    childCount: resourceListState.resources.length + 
                        (resourceListState.hasMore ? 1 : 0),
                  ),
                ),
              ),

            // Empty State
            if (!resourceListState.isLoading && 
                resourceListState.resources.isEmpty && 
                resourceListState.error == null)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        'No resources found',
                        style: TextStyle(
                          fontSize: AppConstants.textLarge,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        'Try adjusting your search or filters',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }
}
