import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Center'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: ListView(
          children: [
            Text(
              'Your Privacy Matters',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'We take your privacy seriously. Learn how we protect your data and control your privacy settings.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            
            _buildPrivacyCard(
              context,
              'Data Protection',
              Icons.security,
              'Your data is encrypted and stored securely.',
            ),
            
            _buildPrivacyCard(
              context,
              'Anonymous Usage',
              Icons.person_off,
              'You can use the app anonymously without revealing your identity.',
            ),
            
            _buildPrivacyCard(
              context,
              'Quick Exit',
              Icons.exit_to_app,
              'Quickly exit the app and show neutral content for privacy.',
            ),
            
            _buildPrivacyCard(
              context,
              'Data Control',
              Icons.settings,
              'Control what data is collected and how it\'s used.',
            ),
            
            _buildPrivacyCard(
              context,
              'Local Storage',
              Icons.storage,
              'Most of your data is stored locally on your device.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXSmall),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
