import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/qa_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/search_bar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/quick_exit_wrapper.dart';

class QAScreen extends ConsumerStatefulWidget {
  const QAScreen({super.key});

  @override
  ConsumerState<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends ConsumerState<QAScreen> {
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
    ref.read(qaCategoriesProvider.notifier).loadCategories();
    ref.read(questionListProvider.notifier).loadQuestions();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(questionListProvider.notifier).loadMoreQuestions();
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      ref.read(questionListProvider.notifier).loadQuestions(refresh: true);
    }
  }

  void _onSearchSubmitted(String query) {
    ref.read(questionListProvider.notifier).searchQuestions(query);
  }

  void _onCategorySelected(String? category) {
    ref.read(questionListProvider.notifier).filterByCategory(category);
  }

  void _onRefresh() {
    ref.read(questionListProvider.notifier).loadQuestions(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final questionListState = ref.watch(questionListProvider);
    final categoriesState = ref.watch(qaCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/qa/ask');
            },
            icon: const Icon(Icons.add),
            tooltip: 'Ask Question',
          ),
        ],
      ),
      body: QuickExitWrapper(
        currentRoute: '/qa',
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
                child: QASearchBar(
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
                  child: QACategoryFilter(
                    categories: categoriesState.categories,
                    onCategorySelected: _onCategorySelected,
                  ),
                ),
              ),

            // Error Message
            if (questionListState.error != null)
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
                              questionListState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(questionListProvider.notifier).clearError();
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
            if (questionListState.isLoading && questionListState.questions.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            // Questions List
            if (questionListState.questions.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == questionListState.questions.length) {
                        // Loading More Indicator
                        return questionListState.isLoadingMore
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppConstants.spacingMedium),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final question = questionListState.questions[index];
                      return QuestionCard(
                        question: question,
                        onTap: () {
                          context.push('/qa/question/${question.id}');
                        },
                      );
                    },
                    childCount: questionListState.questions.length + 
                        (questionListState.hasMore ? 1 : 0),
                  ),
                ),
              ),

            // Empty State
            if (!questionListState.isLoading && 
                questionListState.questions.isEmpty && 
                questionListState.error == null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.question_answer_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        'No questions found',
                        style: TextStyle(
                          fontSize: AppConstants.textLarge,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        'Be the first to ask a question!',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push('/qa/ask');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ask a Question'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/qa/ask');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
