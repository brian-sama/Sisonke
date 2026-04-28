import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../emergency/providers/emergency_provider.dart';
import '../../../core/constants/app_constants.dart';

class SupportDirectoryScreen extends ConsumerWidget {
  const SupportDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(emergencyContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Directory'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: contactsAsync.when(
        data: (response) {
          final categories = response.contacts.keys.toList();
          if (categories.isEmpty) {
            return const Center(child: Text('No support contacts found.'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryContacts = response.contacts[category]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
                    child: Text(
                      AppConstants.emergencyCategoryDisplayNames[category] ?? category.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...categoryContacts.map((contact) => Card(
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
                    child: ListTile(
                      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(contact.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _makePhoneCall(contact.phoneNumber),
                      ),
                    ),
                  )).toList(),
                  const SizedBox(height: AppConstants.spacingMedium),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading contacts'),
              ElevatedButton(
                onPressed: () => ref.refresh(emergencyContactsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
