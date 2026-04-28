import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/resource_provider.dart';
import '../../../shared/models/resource.dart';
import '../../../core/constants/app_constants.dart';

class ResourceDetailScreen extends ConsumerStatefulWidget {
  final String resourceId;

  const ResourceDetailScreen({
    super.key,
    required this.resourceId,
  });

  @override
  ConsumerState<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends ConsumerState<ResourceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resourceProvider(widget.resourceId).notifier).loadResource(widget.resourceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resourceState = ref.watch(resourceProvider(widget.resourceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          resourceState.resource?.title ?? 'Resource',
          style: const TextStyle(fontSize: AppConstants.textLarge),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (resourceState.resource != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(value, resourceState.resource!),
              itemBuilder: (context) => [
                if (resourceState.resource!.isOfflineAvailable)
                  PopupMenuItem(
                    value: 'remove_offline',
                    child: Row(
                      children: const [
                        Icon(Icons.offline_pin_outlined),
                        SizedBox(width: AppConstants.spacingSmall),
                        Text('Remove from Offline'),
                      ],
                    ),
                  )
                else
                  PopupMenuItem(
                    value: 'download_offline',
                    child: Row(
                      children: const [
                        Icon(Icons.download),
                        SizedBox(width: AppConstants.spacingSmall),
                        Text('Download for Offline'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: const [
                      Icon(Icons.share),
                      SizedBox(width: AppConstants.spacingSmall),
                      Text('Share'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: resourceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : resourceState.error != null
              ? _buildErrorState(resourceState.error!)
              : resourceState.resource != null
                  ? _buildResourceBody(resourceState.resource!)
                  : const Center(child: Text('Resource not found')),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'Error loading resource',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton(
              onPressed: () {
                ref.read(resourceProvider(widget.resourceId).notifier).loadResource(widget.resourceId);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceBody(Resource resource) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and metadata
          _buildMetadata(resource),
          const SizedBox(height: AppConstants.spacingLarge),

          // Content
          _buildArticleContent(resource),
          const SizedBox(height: AppConstants.spacingLarge),

          // Tags
          if (resource.tags.isNotEmpty) _buildTags(resource.tags),
          const SizedBox(height: AppConstants.spacingLarge),

          // Offline indicator
          if (resource.isOfflineAvailable) _buildOfflineIndicator(),
        ],
      ),
    );
  }

  Widget _buildMetadata(Resource resource) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSmall,
            vertical: AppConstants.spacingXSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Text(
            AppConstants.categoryDisplayNames[resource.category.name] ?? resource.category.label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: AppConstants.textSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // Reading time and stats
        Row(
          children: [
            if (resource.readingTimeMinutes != null) ...[
              Icon(
                Icons.schedule,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${resource.readingTimeMinutes} min read',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
            ],
            Icon(
              Icons.visibility_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              '${resource.viewCount} views',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacingSmall),

        // Creation date
        Text(
          'Published on ${_formatDate(resource.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(Resource resource) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          resource.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        // Description
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Text(
            resource.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLarge),

        // Full content
        if (resource.content != null) ...[
          Text(
            resource.content!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }

  Widget _buildTags(List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Wrap(
          spacing: AppConstants.spacingXSmall,
          runSpacing: AppConstants.spacingXSmall,
          children: tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSmall,
              vertical: AppConstants.spacingXSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: AppConstants.textSmall,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_pin, color: Colors.green),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Text(
              'This resource is available for offline reading',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Resource resource) async {
    switch (action) {
      case 'download_offline':
        try {
          await ref.read(resourceProvider(widget.resourceId).notifier).downloadForOffline(resource.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resource downloaded for offline use'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to download: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
        break;

      case 'remove_offline':
        try {
          await ref.read(resourceProvider(widget.resourceId).notifier).removeFromOffline(resource.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resource removed from offline storage'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to remove: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
        break;

      case 'share':
        final uri = Uri.parse('https://sisonke.app/resources/${resource.id}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not share resource')),
            );
          }
        }
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
