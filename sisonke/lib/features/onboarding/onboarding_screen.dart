import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/theme/sisonke_colors.dart';
import 'package:sisonke/shared/widgets/index.dart';

/// Streamlined 3-step onboarding:
/// 1. Nickname  2. Companion style  3. Consent + launch
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _api = ApiService();
  final _nicknameController = TextEditingController();
  var _persona = 'female';
  var _consentAccepted = false;
  var _saving = false;
  String? _error;
  int _currentPage = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: SisonkeColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (p) => setState(() => _currentPage = p),
              children: [
                _NicknamePage(controller: _nicknameController, error: _error),
                _CompanionPage(
                  persona: _persona,
                  onChanged: (v) => setState(() => _persona = v),
                ),
                _ConsentPage(
                  accepted: _consentAccepted,
                  onChanged: (v) => setState(() => _consentAccepted = v),
                  error: _error,
                ),
              ],
            ),

            // Bottom navigation — hides when keyboard is up
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              bottom: isKeyboardVisible ? -120 : 24,
              left: 24,
              right: 24,
              child: IgnorePointer(
                ignoring: isKeyboardVisible,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: isKeyboardVisible ? 0 : 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pageCount, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? SisonkeColors.primary
                                  : SisonkeColors.primaryMid,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            Expanded(
                              child: SisonkeButton(
                                label: 'Back',
                                buttonType: ButtonType.secondary,
                                onPressed: () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: SisonkeButton(
                              label: _currentPage == _pageCount - 1
                                  ? (_saving ? 'Starting…' : 'Begin')
                                  : 'Next',
                              isLoading: _saving,
                              onPressed: _onNext,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    setState(() => _error = null);

    if (_currentPage == 0) {
      // Nickname is optional — default to 'Friend' if empty
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (_currentPage == 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Final page
    if (!_consentAccepted) {
      setState(() => _error = 'Please agree to continue.');
      return;
    }
    _finish();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    final nickname = _nicknameController.text.trim().isEmpty
        ? 'Friend'
        : _nicknameController.text.trim();

    try {
      try {
        await _api.saveOnboardingProfile(
          nickname: nickname,
          age: 18,
          gender: 'Prefer not to say',
          location: '',
          chatbotPersona: _persona,
          screeningAnswers: const {},
          pinEnabled: false,
          biometricEnabled: false,
          consentAccepted: true,
        );
      } catch (_) {
        // Backend unavailable — offline-first continues below
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setBool(AppConstants.pinEnabledKey, false);
      await prefs.setBool(AppConstants.biometricEnabledKey, false);
      await prefs.setString('user_nickname', nickname);
      await prefs.setString('user_persona', _persona);

      if (mounted) context.go('/e-friend');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }
}

// ─── Page 1: Nickname ────────────────────────────────────────────────────────

class _NicknamePage extends StatelessWidget {
  final TextEditingController controller;
  final String? error;

  const _NicknamePage({required this.controller, required this.error});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(28, 60, 28, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sisonke',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: SisonkeColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: SisonkeColors.charcoal,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A nickname is fine. You can change this any time in settings.',
            style: TextStyle(
              fontSize: 15,
              color: SisonkeColors.charcoal.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Tino, Sibo, Friend…',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              filled: true,
              fillColor: SisonkeColors.muted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: SisonkeColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: SisonkeColors.danger)),
          ],
        ],
      ),
    );
  }
}

// ─── Page 2: Companion style ─────────────────────────────────────────────────

class _CompanionPage extends StatelessWidget {
  final String persona;
  final ValueChanged<String> onChanged;

  const _CompanionPage({
    required this.persona,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const companions = [
      _Companion(
        id: 'female',
        name: 'Sister',
        quote: '"I\'m here with you. We can take this one breath at a time."',
        icon: Icons.spa_rounded,
        color: Color(0xFFEBCBD0),
      ),
      _Companion(
        id: 'male',
        name: 'Brother',
        quote:
            '"Your thoughts are safe here. I am listening whenever you are ready."',
        icon: Icons.air_rounded,
        color: Color(0xFFD8EEF8),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 60, 28, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sisonke',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: SisonkeColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Who would you like to talk to?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: SisonkeColors.charcoal,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You can switch companions any time during a conversation.',
            style: TextStyle(
              fontSize: 15,
              color: SisonkeColors.charcoal.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          ...companions.map((c) {
            final isSelected = persona == c.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => onChanged(c.id),
                borderRadius: BorderRadius.circular(28),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: c.color,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isSelected
                          ? SisonkeColors.primary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: SisonkeColors.primary.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Colors.white30,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(c.icon, size: 26, color: SisonkeColors.charcoal),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: SisonkeColors.charcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.quote,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: SisonkeColors.charcoal.withOpacity(0.75),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: SisonkeColors.primary,
                            size: 26,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Companion {
  final String id;
  final String name;
  final String quote;
  final IconData icon;
  final Color color;

  const _Companion({
    required this.id,
    required this.name,
    required this.quote,
    required this.icon,
    required this.color,
  });
}

// ─── Page 3: Consent ─────────────────────────────────────────────────────────

class _ConsentPage extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;
  final String? error;

  const _ConsentPage({
    required this.accepted,
    required this.onChanged,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 60, 28, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sisonke',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: SisonkeColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Your space, your privacy.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: SisonkeColors.charcoal,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A few things to know before we begin:',
            style: TextStyle(
              fontSize: 15,
              color: SisonkeColors.charcoal.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 28),
          _ConsentPoint(
            icon: Icons.lock_rounded,
            text:
                'Your mood logs, journal, and counselor chats are private and access-controlled. Only you can see them.',
          ),
          const SizedBox(height: 14),
          _ConsentPoint(
            icon: Icons.groups_rounded,
            text:
                'Community posts are anonymous, age-grouped, and moderated before they appear publicly.',
          ),
          const SizedBox(height: 14),
          _ConsentPoint(
            icon: Icons.health_and_safety_rounded,
            text:
                'Sisonke is not an emergency service. If you are in immediate danger, please contact emergency services.',
          ),
          const SizedBox(height: 28),
          InkWell(
            onTap: () => onChanged(!accepted),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accepted ? SisonkeColors.primaryDim : SisonkeColors.muted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accepted
                      ? SisonkeColors.primary
                      : SisonkeColors.primaryMid,
                  width: accepted ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    accepted
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: accepted
                        ? SisonkeColors.primary
                        : SisonkeColors.charcoal.withOpacity(0.4),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I understand and agree',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: SisonkeColors.charcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: SisonkeColors.danger)),
          ],
        ],
      ),
    );
  }
}

class _ConsentPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ConsentPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SisonkeColors.primaryDim,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: SisonkeColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: SisonkeColors.charcoal.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Kept for backward compat (router.dart references OnboardingPage type nowhere, but
// the language_selection_screen and topic_selection_screen may reference it)
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
