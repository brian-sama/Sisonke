import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/exceptions/api_exception.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/shared/widgets/index.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  final _api = ApiService();
  final _nickname = TextEditingController();
  final _age = TextEditingController(text: '18');
  final _location = TextEditingController();
  var _gender = 'Prefer not to say';
  var _persona = 'female';
  var _pinEnabled = true;
  var _biometricEnabled = false;
  var _consentAccepted = false;
  var _saving = false;
  String? _error;
  int _currentPage = 0;
  final _screeningAnswers = <String, bool>{
    'overwhelmed': false,
    'sleep': false,
    'alone': false,
    'lostInterest': false,
    'unsafe': false,
    'speakToSomeone': false,
  };

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Name or nickname',
      description: 'Choose what the app should call you. A nickname is okay.',
      icon: Icons.badge_outlined,
    ),
    OnboardingPage(
      title: 'Age, gender, and location',
      description:
          'This helps the backend place you in the right age group and show safer content.',
      icon: Icons.person_outline_rounded,
    ),
    OnboardingPage(
      title: 'Consent agreement',
      description:
          'Private spaces stay private. Public posts are moderated for safety.',
      icon: Icons.verified_user_outlined,
    ),
    OnboardingPage(
      title: 'Safety PIN',
      description:
          'Set a PIN for mood logs, journal entries, screening answers, and counseling chats.',
      icon: Icons.pin_outlined,
    ),
    OnboardingPage(
      title: 'Gentle check-in',
      description:
          'Have you felt overwhelmed, struggled to sleep, felt alone, lost interest, felt unsafe, or wanted to speak to someone?',
      icon: Icons.check_circle_outline_rounded,
    ),
    OnboardingPage(
      title: "Choose your Companion's Style",
      description:
          "Select an emotionally safe digital companion archetype that fits your state today.",
      icon: Icons.favorite_outline_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nickname.dispose();
    _age.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return _buildPage(pages[index]);
              },
            ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            Expanded(
                              child: SisonkeButton(
                                label: 'Back',
                                buttonType: ButtonType.secondary,
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: SisonkeButton(
                              label: _currentPage == pages.length - 1
                                  ? (_saving ? 'Saving...' : 'Get Started')
                                  : 'Next',
                              isLoading: _saving,
                              onPressed: () {
                                if (_currentPage == pages.length - 1) {
                                  _finishOnboarding();
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
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

  Widget _buildPage(OnboardingPage page) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardVisible = keyboardInset > 0;
    final bottomPadding = isKeyboardVisible ? keyboardInset + 32 : 156.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentMinHeight = (constraints.maxHeight - bottomPadding)
            .clamp(0.0, double.infinity)
            .toDouble();

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            isKeyboardVisible ? 16 : 24,
            24,
            bottomPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: contentMinHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  page.icon,
                  size: isKeyboardVisible ? 72 : 100,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: isKeyboardVisible ? 20 : 32),
                Text(
                  page.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildStepFields(),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepFields() {
    switch (_currentPage) {
      case 0:
        return TextField(
          controller: _nickname,
          decoration: const InputDecoration(
            labelText: 'Nickname',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        );
      case 1:
        return Column(
          children: [
            TextField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              items: const ['Female', 'Male', 'Non-binary', 'Prefer not to say']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _gender = value ?? _gender),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _location,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ],
        );
      case 2:
        return _ConsentPanel(
          accepted: _consentAccepted,
          onChanged: (value) => setState(() => _consentAccepted = value),
        );
      case 3:
        return Column(
          children: [
            SwitchListTile(
              value: _pinEnabled,
              onChanged: (value) => setState(() => _pinEnabled = value),
              title: const Text('Enable PIN lock'),
            ),
            SwitchListTile(
              value: _biometricEnabled,
              onChanged: (value) => setState(() => _biometricEnabled = value),
              title: const Text('Enable biometric unlock'),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            _CheckTile(
              label: 'Have you felt overwhelmed recently?',
              value: _screeningAnswers['overwhelmed']!,
              onChanged: (value) => _setAnswer('overwhelmed', value),
            ),
            _CheckTile(
              label: 'Have you struggled to sleep?',
              value: _screeningAnswers['sleep']!,
              onChanged: (value) => _setAnswer('sleep', value),
            ),
            _CheckTile(
              label: 'Have you felt alone or unsupported?',
              value: _screeningAnswers['alone']!,
              onChanged: (value) => _setAnswer('alone', value),
            ),
            _CheckTile(
              label: 'Have you lost interest in things you enjoy?',
              value: _screeningAnswers['lostInterest']!,
              onChanged: (value) => _setAnswer('lostInterest', value),
            ),
            _CheckTile(
              label: 'Have you felt unsafe or at risk?',
              value: _screeningAnswers['unsafe']!,
              onChanged: (value) => _setAnswer('unsafe', value),
            ),
            _CheckTile(
              label: 'Would you like to speak to someone?',
              value: _screeningAnswers['speakToSomeone']!,
              onChanged: (value) => _setAnswer('speakToSomeone', value),
            ),
          ],
        );
      case 5:
        final styles = [
          {
            'id': 'female', // Soft & Understanding
            'name': 'Soft & Understanding',
            'quote':
                '“I’m here with you. We can take this one step at a time.”',
            'icon': Icons.spa_rounded,
            'color': const Color(0xFFEBCBD0), // blush
          },
          {
            'id': 'female_calm', // Calm & Encouraging
            'name': 'Calm & Encouraging',
            'quote':
                '“You are doing better than you think. Let’s find your balance.”',
            'icon': Icons.wb_sunny_rounded,
            'color': const Color(0xFFCFE6D2), // sage
          },
          {
            'id': 'male', // Gentle Listener
            'name': 'Gentle Listener',
            'quote':
                '“Your thoughts are safe here. I am listening whenever you are ready.”',
            'icon': Icons.hearing_rounded,
            'color': const Color(0xFFD8EEF8), // sky
          },
          {
            'id': 'female_motivating', // Motivating Friend
            'name': 'Motivating Friend',
            'quote':
                '“I believe in you! Let’s take on small, joyful steps together today.”',
            'icon': Icons.bolt_rounded,
            'color': const Color(0xFFF7E8B5), // lemon
          },
          {
            'id': 'male_quiet', // Quiet & Comforting
            'name': 'Quiet & Comforting',
            'quote':
                '“No pressure to speak. Let’s just sit in quiet reflection together.”',
            'icon': Icons.nightlight_round,
            'color': const Color(0xFFE4DDF6), // lavender
          },
        ];

        return Column(
          children: styles.map((style) {
            final isSelected = _persona == style['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _persona = style['id'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: style['color'] as Color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E6F60) // AppTheme.primary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (style['color'] as Color).withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          style['icon'] as IconData,
                          size: 28,
                          color: const Color(0xFF2F3433), // charcoal
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              style['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F3433),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              style['quote'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: const Color(
                                  0xFF2F3433,
                                ).withValues(alpha: 0.85),
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
              ),
            );
          }).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _setAnswer(String key, bool value) {
    setState(() => _screeningAnswers[key] = value);
  }

  Future<void> _finishOnboarding() async {
    final age = int.tryParse(_age.text.trim()) ?? 18;
    final nickname = _nickname.text.trim().isEmpty
        ? 'Friend'
        : _nickname.text.trim();

    if (!_consentAccepted) {
      setState(
        () => _error = 'Please review and accept consent before continuing.',
      );
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final dbPersona = _persona.startsWith('female') ? 'female' : 'male';
      await _api.saveOnboardingProfile(
        nickname: nickname,
        age: age,
        gender: _gender,
        location: _location.text.trim(),
        chatbotPersona: dbPersona,
        screeningAnswers: _screeningAnswers,
        pinEnabled: _pinEnabled,
        biometricEnabled: _biometricEnabled,
        consentAccepted: _consentAccepted,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setBool(AppConstants.pinEnabledKey, _pinEnabled);
      await prefs.setBool(
        AppConstants.biometricEnabledKey,
        _pinEnabled && _biometricEnabled,
      );
      if (mounted) context.go(_pinEnabled ? '/app-lock' : '/home');
    } catch (e) {
      debugPrint('Onboarding error: $e');
      if (!mounted) return;
      String errorMsg =
          'Could not save your profile. Check that the backend is running.';
      if (e is ApiException) {
        errorMsg = e.message;
      } else if (e is DioException) {
        if (e.response?.data is Map && e.response?.data['error'] != null) {
          errorMsg =
              e.response?.data['error']?.toString() ?? 'Could not save profile';
        } else if (e.message != null) {
          errorMsg = e.message!;
        }
      }
      setState(() {
        _saving = false;
        _error = errorMsg;
      });
    }
  }
}

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

class _ConsentPanel extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;

  const _ConsentPanel({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _ConsentLine(
              icon: Icons.lock_rounded,
              text:
                  'Mood, journal, and counselor spaces are private and access-controlled.',
            ),
            const _ConsentLine(
              icon: Icons.groups_rounded,
              text:
                  'Community posts are anonymous, age-grouped, and moderated before public display.',
            ),
            const _ConsentLine(
              icon: Icons.health_and_safety_rounded,
              text:
                  'Sisonke is not an emergency or medical service. Serious safety concerns may be escalated to authorized support roles.',
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: (value) => onChanged(value ?? false),
              title: const Text('I understand and agree'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ConsentLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (checked) => onChanged(checked ?? false),
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
