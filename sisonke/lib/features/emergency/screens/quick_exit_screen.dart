import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

class QuickExitScreen extends StatefulWidget {
  const QuickExitScreen({super.key});

  @override
  State<QuickExitScreen> createState() => _QuickExitScreenState();
}

class _QuickExitScreenState extends State<QuickExitScreen> {
  String _trigger = 'Back Button (x2)';
  String _fakeScreen = 'Weather App';
  bool _stealthMode = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Quick Exit Settings'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(colorScheme),
          const SizedBox(height: 24),
          Text(
            'ACTIVATION TRIGGER',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTriggerOption('Back Button (x2)', 'Tap back twice quickly', Icons.history_rounded),
          _buildTriggerOption('Volume Buttons', 'Hold both volume buttons', Icons.volume_up_rounded),
          _buildTriggerOption('Shake Device', 'Vigorously shake your phone', Icons.vibration_rounded),
          const SizedBox(height: 32),
          Text(
            'FAKE LANDING PAGE',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLandingOption('Weather App', 'Shows local weather forecast', Icons.wb_sunny_rounded),
          _buildLandingOption('News Feed', 'Shows latest neutral news', Icons.article_rounded),
          _buildLandingOption('Calculator', 'Basic calculator interface', Icons.calculate_rounded),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text('Stealth Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('No haptic feedback when activating'),
            value: _stealthMode,
            onChanged: (val) => setState(() => _stealthMode = val),
            activeColor: colorScheme.primary,
          ),
          const SizedBox(height: 40),
          SisonkeButton(
            label: 'Save Configuration',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quick Exit settings saved')),
              );
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: colorScheme.primary, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Quick Exit immediately hides Sisonke and opens a fake screen if someone enters the room.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerOption(String title, String sub, IconData icon) {
    final selected = _trigger == title;
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(sub),
      secondary: Icon(icon, color: selected ? null : Colors.grey),
      value: title,
      groupValue: _trigger,
      onChanged: (val) => setState(() => _trigger = val!),
    );
  }

  Widget _buildLandingOption(String title, String sub, IconData icon) {
    final selected = _fakeScreen == title;
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(sub),
      secondary: Icon(icon, color: selected ? null : Colors.grey),
      value: title,
      groupValue: _fakeScreen,
      onChanged: (val) => setState(() => _fakeScreen = val!),
    );
  }
}

