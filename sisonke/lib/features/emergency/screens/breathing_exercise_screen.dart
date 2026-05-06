import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../theme/sisonke_colors.dart';
import '../../../shared/widgets/index.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExercising = false;
  int _currentCycle = 0;
  int _totalCycles = 4;
  String _currentPhase = 'Ready';

  // Ambient sound states
  bool _riverOn = false;
  bool _rainOn = false;
  bool _pianoOn = true; // default active

  @override
  void initState() {
    super.initState();
    // 4-second duration matching the Box Breathing count
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isExercising = true;
      _currentCycle = 0;
      _currentPhase = 'Inhale';
    });
    _runBreathingCycle();
  }

  Future<void> _runBreathingCycle() async {
    for (int cycle = 0; cycle < _totalCycles; cycle++) {
      if (!mounted || !_isExercising) break;
      setState(() {
        _currentCycle = cycle + 1;
      });

      // 1. Inhale (4s) - scale up
      setState(() => _currentPhase = 'Inhale');
      await _controller.forward();
      if (!mounted || !_isExercising) return;

      // 2. Hold (4s) - stay scaled, pulse glow
      setState(() => _currentPhase = 'Hold');
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted || !_isExercising) return;

      // 3. Exhale (4s) - scale down
      setState(() => _currentPhase = 'Exhale');
      await _controller.reverse();
      if (!mounted || !_isExercising) return;

      // 4. Hold (4s) - wait
      setState(() => _currentPhase = 'Rest');
      await Future.delayed(const Duration(seconds: 4));
    }

    if (mounted) {
      setState(() {
        _isExercising = false;
        _currentPhase = 'Complete';
      });
    }
  }

  void _resetExercise() {
    _controller.reset();
    setState(() {
      _isExercising = false;
      _currentCycle = 0;
      _currentPhase = 'Ready';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(
        title: 'Breathing Companion',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: SisonkeColors.morningMist,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Box Breathing Rhythm',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2F3433),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'A natural 4-4-4-4 cycle that anchors your awareness and stabilizes tension.',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF2F3433).withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // --- Ready and Default Layout ---
                    if (_currentPhase == 'Ready' || _currentPhase == 'Complete') ...[
                      _buildStaticLeafView(),
                    ],

                    // --- Interactive Exercise Loop ---
                    if (_isExercising) ...[
                      _buildBreathingAnimationView(),
                    ],
                  ],
                ),
              ),
            ),

            // --- Sound Options & Start Tray ---
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  // Large growing leaf asset for static phases
  Widget _buildStaticLeafView() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Soft background halo
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCFE6D2).withOpacity(0.35),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
            // The Leaf container
            Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E6F60),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(120),
                    bottomRight: Radius.circular(120),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 54,
                  color: Color(0xFFCFE6D2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (_currentPhase == 'Complete') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF2E6F60)),
                    SizedBox(width: 8),
                    Text(
                      'Rhythm Complete',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2F3433)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your heart rate and body thank you. Keep this peacefulness as you continue your day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: const Color(0xFF2F3433).withOpacity(0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  // Active breathing animation screen
  Widget _buildBreathingAnimationView() {
    return Column(
      children: [
        Text(
          'Cycle $_currentCycle of $_totalCycles',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E6F60),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 28),

        // Animated organic growing leaf
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scaleValue = _scaleAnimation.value;
            final rotValue = _rotationAnimation.value;

            // Highlight glow when holding breath
            final glowOn = _currentPhase == 'Hold';

            return Stack(
              alignment: Alignment.center,
              children: [
                // Glowing background aura
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 170 * scaleValue,
                  height: 170 * scaleValue,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowOn 
                        ? const Color(0xFFFFC857).withOpacity(0.24) 
                        : const Color(0xFFCFE6D2).withOpacity(0.3),
                    boxShadow: glowOn
                        ? [
                            const BoxShadow(
                              color: Color(0xFFFFC857),
                              blurRadius: 36,
                              spreadRadius: 8,
                            )
                          ]
                        : null,
                  ),
                ),
                // Rotational, scaling leaf
                Transform.rotate(
                  angle: -0.4 + rotValue,
                  child: Transform.scale(
                    scale: scaleValue,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E6F60),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(120),
                          bottomRight: Radius.circular(120),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 48,
                        color: Color(0xFFCFE6D2),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 36),

        // Phase prompt
        Text(
          _currentPhase.toUpperCase(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2E6F60),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),

        // Instructional helper phrasing
        _buildHelperInstruction(),
        const SizedBox(height: 36),

        // Quiet Cancel
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: const Color(0xFF2E6F60).withOpacity(0.3)),
          ),
          onPressed: _resetExercise,
          icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF2E6F60)),
          label: const Text('End Rhythm', style: TextStyle(color: Color(0xFF2F3433), fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildHelperInstruction() {
    String message = '';
    if (_currentPhase == 'Inhale') {
      message = 'Inhale slowly, feeling the leaf fill with air.';
    } else if (_currentPhase == 'Hold') {
      message = 'Hold quietly, resting in your space.';
    } else if (_currentPhase == 'Exhale') {
      message = 'Exhale gently, letting the tension fall away.';
    } else if (_currentPhase == 'Rest') {
      message = 'Pause for a brief, peaceful moment.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2F3433).withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ambient Soundscapes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2F3433)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E6F60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Visualizers active', style: TextStyle(fontSize: 10, color: Color(0xFF2E6F60), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Soundscapes selection row
          Row(
            children: [
              _buildSoundButton('🏞️ River', _riverOn, () {
                setState(() {
                  _riverOn = !_riverOn;
                });
              }),
              const SizedBox(width: 8),
              _buildSoundButton('🌧️ Rain', _rainOn, () {
                setState(() {
                  _rainOn = !_rainOn;
                });
              }),
              const SizedBox(width: 8),
              _buildSoundButton('🎹 Piano', _pianoOn, () {
                setState(() {
                  _pianoOn = !_pianoOn;
                });
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Main Trigger Button
          SisonkeButton(
            onPressed: _startExercise,
            isEnabled: !_isExercising,
            label: _isExercising ? 'Breathing in rhythm...' : 'Begin 1-Minute Breath',
            icon: Icons.self_improvement_rounded,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSoundButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2E6F60).withOpacity(0.12) : Colors.white60,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? const Color(0xFF2E6F60) : Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: const Color(0xFF2F3433),
                ),
              ),
              if (active) ...[
                const SizedBox(height: 6),
                _SoundwaveVisualizer(active: active),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Micro soundwave animation widget
class _SoundwaveVisualizer extends StatefulWidget {
  final bool active;
  const _SoundwaveVisualizer({required this.active});

  @override
  State<_SoundwaveVisualizer> createState() => _SoundwaveVisualizerState();
}

class _SoundwaveVisualizerState extends State<_SoundwaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final delay = index * 0.22;
            final raw = _waveController.value - delay;
            final value = math.sin(raw * math.pi).abs();
            final height = 3.0 + (value * 12.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 2,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF2E6F60),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
