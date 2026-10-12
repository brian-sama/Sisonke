import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/core/services/security_service.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    final results = await Future.wait([
      _determineDestination(),
      Future.delayed(const Duration(milliseconds: 900)),
    ]);
    if (!mounted) return;
    context.go(results[0] as String);
  }

  Future<String> _determineDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = ApiService();
    final securityService = SecurityService();
    final hasCompletedOnboarding =
        prefs.getBool('onboarding_completed') ?? false;
    final isAuthenticated = await apiService.isAuthenticated;
    final pinEnabled = prefs.getBool(AppConstants.pinEnabledKey) ?? false;
    final hasPin = await securityService.hasPIN();

    if (hasCompletedOnboarding || isAuthenticated) {
      return (pinEnabled || hasPin) ? '/app-lock' : '/home';
    }
    return '/onboarding';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.scaffoldBackgroundColor : SisonkeColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F121C) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SisonkeColors.primary.withValues(
                      alpha: isDark ? 0.3 : 0.12,
                    ),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.health_and_safety_rounded,
                    size: 56,
                    color: SisonkeColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Serevo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : SisonkeColors.serevoText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mental Health & Psychosocial Support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : SisonkeColors.charcoalSoft,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? theme.colorScheme.primary : SisonkeColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
