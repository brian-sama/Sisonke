import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/features/emergency/providers/emergency_provider.dart';
import 'package:sisonke/shared/widgets/index.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class EmergencyToolkitScreen extends ConsumerWidget {
  const EmergencyToolkitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolkitAsync = ref.watch(emergencyToolkitProvider);

    return Scaffold(
      appBar: const SisonkeAppBar(
        title: 'Emergency Toolkit',
        fallbackBackLocation: '/home',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: SisonkeColors.forestBreeze,
        ),
        child: toolkitAsync.when(
          data: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // Crisis Banner Shortcut
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Are you in acute distress?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Open our step-by-step calming crisis pathway.',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF991B1B).withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF43F5E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => context.push('/crisis-pathway'),
                      child: const Text('Open', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SoftSectionHeader(
                title: 'Self-Help Tools',
                subtitle: 'Gentle, scientifically proven techniques to calm your mind and body.',
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
                children: [
                  _ToolkitCard(
                    title: 'Breathing',
                    subtitle: 'Box rhythm calming',
                    icon: Icons.air_rounded,
                    accentColor: const Color(0xFF2E6F60),
                    bgTint: const Color(0xFFE8F5F1),
                    onTap: () => context.push('/breathing'),
                  ),
                  _ToolkitCard(
                    title: 'Grounding',
                    subtitle: '5-4-3-2-1 technique',
                    icon: Icons.spa_rounded,
                    accentColor: const Color(0xFFD97706),
                    bgTint: const Color(0xFFFEF3C7),
                    onTap: () => context.push('/grounding'),
                  ),
                  _ToolkitCard(
                    title: 'Safety Plan',
                    subtitle: 'My personal triggers & contacts',
                    icon: Icons.shield_outlined,
                    accentColor: const Color(0xFFD68A7F),
                    bgTint: const Color(0xFFFCEFEF),
                    onTap: () => context.push('/safety-plan'),
                  ),
                  _ToolkitCard(
                    title: 'Helplines',
                    subtitle: 'Direct contacts & counselors',
                    icon: Icons.phone_in_talk_rounded,
                    accentColor: const Color(0xFFF43F5E),
                    bgTint: const Color(0xFFFEE2E2),
                    onTap: () => context.push('/support'),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E6F60)),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFD68A7F)),
                  const SizedBox(height: 14),
                  const Text(
                    'Failed to load emergency tools',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SisonkeButton(
                    label: 'Retry',
                    onPressed: () => ref.refresh(emergencyToolkitProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolkitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgTint;
  final VoidCallback onTap;

  const _ToolkitCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgTint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: accentColor),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3433),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF2F3433).withValues(alpha: 0.6),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
