import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/providers/app_preferences_provider.dart';
import 'package:sisonke/shared/widgets/index.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸', 'subtitle': 'Welcome'},
      {'code': 'sn', 'name': 'chiShona', 'flag': '🇿🇼', 'subtitle': 'Mauya'},
      {'code': 'nd', 'name': 'isiNdebele', 'flag': '🇿🇼', 'subtitle': 'Samukele'},
    ];

    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Choose Language'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Icon(
                Icons.translate_rounded,
                size: 80,
                color: Color(0xFF2E6F60),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select your language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E6F60),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This will update the interface language of the application.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = currentLanguage == lang['code'];
                    return InkWell(
                      onTap: () {
                        ref.read(languageProvider.notifier).state = lang['code']!;
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2E6F60).withOpacity(0.08) : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2E6F60) : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              lang['flag']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang['name']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF2E6F60) : Colors.black80,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lang['subtitle']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? const Color(0xFF2E6F60).withOpacity(0.7) : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF2E6F60),
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/onboarding');
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6F60),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
