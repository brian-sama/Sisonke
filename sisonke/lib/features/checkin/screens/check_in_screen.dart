import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          children: [
            Text(
              'Daily Check-In',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.spacingMedium,
                mainAxisSpacing: AppConstants.spacingMedium,
                children: [
                  _buildCheckInCard(
                    context,
                    'Mood Tracker',
                    Icons.mood,
                    Colors.blue,
                    () => context.push('/check-in/mood'),
                  ),
                  _buildCheckInCard(
                    context,
                    'Journal',
                    Icons.book,
                    Colors.green,
                    () => context.push('/check-in/journal'),
                  ),
                  _buildCheckInCard(
                    context,
                    'Recovery',
                    Icons.healing,
                    Colors.orange,
                    () => context.push('/check-in/recovery'),
                  ),
                  _buildCheckInCard(
                    context,
                    'Progress',
                    Icons.trending_up,
                    Colors.purple,
                    () => context.push('/check-in/mood'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
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
