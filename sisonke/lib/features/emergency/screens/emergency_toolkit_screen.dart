import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/emergency_provider.dart';
import '../../../core/constants/app_constants.dart';

class EmergencyToolkitScreen extends ConsumerWidget {
  const EmergencyToolkitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolkitAsync = ref.watch(emergencyToolkitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Toolkit'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: toolkitAsync.when(
        data: (toolkit) => Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Self-Help Tools',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              const Text('Quick techniques to help you stay calm and grounded.'),
              const SizedBox(height: AppConstants.spacingLarge),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spacingMedium,
                  mainAxisSpacing: AppConstants.spacingMedium,
                  children: [
                    _buildToolCard(
                      context,
                      'Breathing',
                      Icons.air,
                      Colors.blue,
                      () => context.push('/breathing'),
                    ),
                    _buildToolCard(
                      context,
                      'Grounding',
                      Icons.grass,
                      Colors.green,
                      () => context.push('/grounding'),
                    ),
                    _buildToolCard(
                      context,
                      'Safety Plan',
                      Icons.security,
                      Colors.orange,
                      () => context.push('/safety-plan'),
                    ),
                    _buildToolCard(
                      context,
                      'Helplines',
                      Icons.phone,
                      Colors.red,
                      () => context.push('/support/directory'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load toolkit'),
              ElevatedButton(
                onPressed: () => ref.refresh(emergencyToolkitProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
