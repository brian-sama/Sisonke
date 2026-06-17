import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class CrisisPathwayScreen extends StatefulWidget {
  const CrisisPathwayScreen({super.key});

  @override
  State<CrisisPathwayScreen> createState() => _CrisisPathwayScreenState();
}

class _CrisisPathwayScreenState extends State<CrisisPathwayScreen> {
  int _activeStep = 0;
  Timer? _autoAdvanceTimer;

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _advanceTo(int step) {
    _autoAdvanceTimer?.cancel();
    setState(() => _activeStep = step);
  }

  void _startBreathing() {
    context.push('/breathing');
    _autoAdvanceTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _advanceTo(1);
    });
  }

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:999');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: SisonkeColors.pastelSunset),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const Icon(
                          Icons.favorite_rounded,
                          color: SisonkeColors.accent,
                          size: 28,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: SisonkeColors.charcoal,
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are not alone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: SisonkeColors.charcoal,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Let’s take this one step at a time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: SisonkeColors.charcoal.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),

              // Step cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [
                    _StepCard(
                      step: 0,
                      activeStep: _activeStep,
                      stepNumber: '1',
                      title: 'Breathe first',
                      description:
                          'Take 2 minutes. Your body needs to calm before your mind can.',
                      primaryLabel: 'Start breathing',
                      secondaryLabel: 'I’ve done this',
                      onPrimary: _startBreathing,
                      onSecondary: () => _advanceTo(1),
                      onHeaderTap: () => _advanceTo(0),
                    ),
                    const SizedBox(height: 12),
                    _StepCard(
                      step: 1,
                      activeStep: _activeStep,
                      stepNumber: '2',
                      title: 'Your safety plan',
                      description:
                          'You made this for moments like this. Let’s look at it together.',
                      primaryLabel: 'Open my safety plan',
                      secondaryLabel: 'Next step',
                      onPrimary: () => context.push('/safety-plan'),
                      onSecondary: () => _advanceTo(2),
                      onHeaderTap: () => _advanceTo(1),
                    ),
                    const SizedBox(height: 12),
                    _StepCard(
                      step: 2,
                      activeStep: _activeStep,
                      stepNumber: '3',
                      title: 'Talk to someone',
                      description:
                          'A trained counselor is ready. You deserve real human support.',
                      primaryLabel: 'Connect with a counselor',
                      secondaryLabel: null,
                      onPrimary: () => context.go('/support/counselor'),
                      onSecondary: null,
                      onHeaderTap: () => _advanceTo(2),
                      extraAction: TextButton.icon(
                        onPressed: _callEmergency,
                        icon: const Icon(
                          Icons.call_rounded,
                          size: 18,
                          color: SisonkeColors.danger,
                        ),
                        label: const Text(
                          'Call emergency services',
                          style: TextStyle(
                            color: SisonkeColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Text(
                  'You can close this screen and come back whenever you need.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: SisonkeColors.charcoal.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final int activeStep;
  final String stepNumber;
  final String title;
  final String description;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final VoidCallback onHeaderTap;
  final Widget? extraAction;

  const _StepCard({
    required this.step,
    required this.activeStep,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    required this.onHeaderTap,
    this.extraAction,
  });

  bool get _isActive => step == activeStep;
  bool get _isCompleted => step < activeStep;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isActive
            ? Colors.white.withOpacity(0.92)
            : Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _isActive
              ? SisonkeColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: _isActive
            ? [
                BoxShadow(
                  color: SisonkeColors.primary.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: InkWell(
        onTap: _isActive ? null : onHeaderTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step header row
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCompleted
                          ? SisonkeColors.success
                          : _isActive
                              ? SisonkeColors.primary
                              : SisonkeColors.primaryDim,
                    ),
                    child: Center(
                      child: _isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            )
                          : Text(
                              stepNumber,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _isActive
                                    ? Colors.white
                                    : SisonkeColors.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _isActive
                            ? SisonkeColors.charcoal
                            : SisonkeColors.charcoal.withOpacity(0.55),
                      ),
                    ),
                  ),
                  if (!_isActive)
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: SisonkeColors.charcoal.withOpacity(0.35),
                    ),
                ],
              ),

              // Expanded content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: SisonkeColors.charcoal.withOpacity(0.75),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onPrimary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SisonkeColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          primaryLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    if (secondaryLabel != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: onSecondary,
                          style: TextButton.styleFrom(
                            foregroundColor: SisonkeColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            secondaryLabel!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (extraAction != null) ...[
                      const SizedBox(height: 8),
                      Center(child: extraAction!),
                    ],
                  ],
                ),
                crossFadeState: _isActive
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
