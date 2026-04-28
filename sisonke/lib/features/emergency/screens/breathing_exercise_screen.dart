import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExercising = false;
  int _currentCycle = 0;
  int _totalCycles = 4;
  String _currentPhase = 'Ready';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 2.0).animate(
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
      setState(() {
        _currentCycle = cycle + 1;
      });

      // Inhale
      setState(() => _currentPhase = 'Inhale');
      await _controller.forward();
      await Future.delayed(const Duration(seconds: 1));

      // Hold
      setState(() => _currentPhase = 'Hold');
      await Future.delayed(const Duration(seconds: 4));

      // Exhale
      setState(() => _currentPhase = 'Exhale');
      await _controller.reverse();
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _isExercising = false;
      _currentPhase = 'Complete';
    });
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
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          children: [
            Text(
              'Box Breathing',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              '4-4-4-4 breathing technique to reduce stress and anxiety.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            if (!_isExercising)
              Column(
                children: [
                  // Breathing circle
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.air,
                            size: 80 * _animation.value,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),

                  Text(
                    'Box breathing helps regulate your nervous system and reduce stress.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMedium),
                      ),
                      child: const Text('Start Exercise'),
                    ),
                  ),
                ],
              ),

            if (_isExercising)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cycle counter
                    Text(
                      'Cycle $_currentCycle of $_totalCycles',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),

                    // Animated breathing circle
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.air,
                              size: 80 * _animation.value,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),

                    // Current phase
                    Text(
                      _currentPhase,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),

                    // Phase instructions
                    if (_currentPhase == 'Inhale')
                      const Text('Breathe in slowly through your nose')
                    else if (_currentPhase == 'Hold')
                      const Text('Hold your breath')
                    else if (_currentPhase == 'Exhale')
                      const Text('Breathe out slowly through your mouth'),

                    const SizedBox(height: AppConstants.spacingLarge),

                    // Cancel button
                    OutlinedButton(
                      onPressed: _resetExercise,
                      child: const Text('Cancel Exercise'),
                    ),
                  ],
                ),
              ),

            if (_currentPhase == 'Complete')
              Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  Text(
                    'Exercise Complete!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    'Great job! You completed the breathing exercise.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Start Again'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
