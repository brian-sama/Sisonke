import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class SafetyPlanScreen extends StatelessWidget {
  const SafetyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Plan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: ListView(
          children: [
            Text(
              'Your Safety Plan',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'A safety plan helps you stay safe during difficult times.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            
            _buildSection(
              context,
              'Warning Signs',
              'Recognize when you need help',
              Icons.warning,
              [
                'Feeling overwhelmed',
                'Thoughts of self-harm',
                'Increased anxiety',
                'Difficulty sleeping',
              ],
            ),
            
            _buildSection(
              context,
              'Coping Strategies',
              'Things that help you feel better',
              Icons.psychology,
              [
                'Deep breathing exercises',
                'Call a trusted friend',
                'Listen to calming music',
                'Go for a walk',
              ],
            ),
            
            _buildSection(
              context,
              'Trusted Contacts',
              'People you can call for support',
              Icons.people,
              [
                'Friend: +263 123 456 789',
                'Family Member: +263 987 654 321',
                'Counselor: +263 555 123 456',
              ],
            ),
            
            _buildSection(
              context,
              'Professional Help',
              'Emergency and professional contacts',
              Icons.local_hospital,
              [
                'Emergency: 999',
                'Lifeline: +263 772 161 917',
                'Mental Health: +263 772 161 918',
              ],
            ),
            
            _buildSection(
              context,
              'Safe Places',
              'Places where you feel safe',
              Icons.location_on,
              [
                'Home',
                'Friend\'s house',
                'Community center',
                'Place of worship',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    List<String> items,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingXSmall),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
