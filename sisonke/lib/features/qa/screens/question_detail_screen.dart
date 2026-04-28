import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/qa_provider.dart';
import '../../../core/constants/app_constants.dart';

class QuestionDetailScreen extends ConsumerWidget {
  final String questionId;

  const QuestionDetailScreen({
    super.key,
    required this.questionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionState = ref.watch(questionProvider(questionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: questionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : questionState.error != null
              ? Center(child: Text('Error: ${questionState.error}'))
              : questionState.question == null
                  ? const Center(child: Text('Question not found'))
                  : _buildContent(context, ref, questionState.question!),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic data) {
    final question = data.question;
    final answers = data.answers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              question.category.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          
          // Question Title
          Text(
            question.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          
          // Timestamp
          Text(
            DateFormat('MMM dd, yyyy').format(question.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          
          // Description
          Text(
            question.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppConstants.spacingXLarge),
          
          const Divider(),
          const SizedBox(height: AppConstants.spacingMedium),
          
          // Answers Section
          Text(
            'Answers (${answers.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          
          if (answers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No answers yet. Our experts will respond soon.'),
            )
          else
            ...answers.map((answer) => _buildAnswerCard(context, ref, answer)).toList(),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(BuildContext context, WidgetRef ref, dynamic answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.expertName ?? 'Sisonke Expert',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (answer.expertRole != null)
                      Text(
                        answer.expertRole!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(answer.content),
            const SizedBox(height: AppConstants.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(answer.answeredAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up_outlined, size: 20),
                      onPressed: () {
                        ref.read(questionProvider(questionId).notifier).markAnswerHelpful(answer.id);
                      },
                    ),
                    Text('${answer.helpfulCount}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
