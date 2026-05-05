import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/quick_exit_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/quick_exit_button.dart';

class QuickExitSettingsScreen extends ConsumerStatefulWidget {
  const QuickExitSettingsScreen({super.key});

  @override
  ConsumerState<QuickExitSettingsScreen> createState() =>
      _QuickExitSettingsScreenState();
}

class _QuickExitSettingsScreenState
    extends ConsumerState<QuickExitSettingsScreen> {
  late QuickExitService _quickExitService;
  bool _isEnabled = true;
  QuickExitDestination _selectedDestination = QuickExitDestination.blank;
  bool _showButton = true;
  bool _enableBackPress = false;
  bool _enableShake = false;
  bool _enableVolumeKeys = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _quickExitService = QuickExitService(prefs);

    setState(() {
      _isEnabled = _quickExitService.isQuickExitEnabled;
      _selectedDestination = _quickExitService.getQuickExitDestination();

      // Load trigger methods
      final methods = _quickExitService.getQuickExitMethods();
      _showButton = methods.contains(QuickExitMethod.button);
      _enableBackPress = methods.contains(QuickExitMethod.backPress);
      _enableShake = methods.contains(QuickExitMethod.shake);
      _enableVolumeKeys = methods.contains(QuickExitMethod.volumeKeys);
    });
  }

  Future<void> _saveSettings() async {
    await _quickExitService.setQuickExitEnabled(_isEnabled);
    await _quickExitService.setQuickExitDestination(_selectedDestination);
    await _quickExitService.setQuickExitMethods(
      button: _showButton,
      backPress: _enableBackPress,
      shake: _enableShake,
      volumeKeys: _enableVolumeKeys,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Exit Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        children: [
          // Enable/Disable Quick Exit
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Exit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'Quickly exit the app and show neutral content for privacy and safety.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  SwitchListTile(
                    title: const Text('Enable Quick Exit'),
                    subtitle: const Text('Allow Quick Exit functionality'),
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Quick Exit Destination
          if (_isEnabled)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Exit Destination',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    RadioListTile<QuickExitDestination>(
                      title: const Text('Blank screen'),
                      subtitle: const Text('Show a neutral empty screen'),
                      value: QuickExitDestination.blank,
                      groupValue: _selectedDestination,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value!;
                        });
                        _saveSettings();
                      },
                    ),
                    RadioListTile<QuickExitDestination>(
                      title: const Text('Calculator'),
                      subtitle: const Text('Show a calculator'),
                      value: QuickExitDestination.calculator,
                      groupValue: _selectedDestination,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value!;
                        });
                        _saveSettings();
                      },
                    ),
                    RadioListTile<QuickExitDestination>(
                      title: const Text('Notes'),
                      subtitle: const Text('Show personal notes'),
                      value: QuickExitDestination.notes,
                      groupValue: _selectedDestination,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value!;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Trigger Methods
          if (_isEnabled)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trigger Methods',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    SwitchListTile(
                      title: const Text('Quick Exit Button'),
                      subtitle: const Text('Show floating Quick Exit button'),
                      value: _showButton,
                      onChanged: (value) {
                        setState(() {
                          _showButton = value;
                        });
                        _saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Back Button'),
                      subtitle: const Text(
                        'Off by default so back stays normal navigation',
                      ),
                      value: _enableBackPress,
                      onChanged: (value) {
                        setState(() {
                          _enableBackPress = value;
                        });
                        _saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Shake Device'),
                      subtitle: const Text('Shake phone to Quick Exit'),
                      value: _enableShake,
                      onChanged: (value) {
                        setState(() {
                          _enableShake = value;
                        });
                        _saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Volume Keys'),
                      subtitle: const Text(
                        'Press volume keys 3 times to Quick Exit',
                      ),
                      value: _enableVolumeKeys,
                      onChanged: (value) {
                        setState(() {
                          _enableVolumeKeys = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Test Quick Exit
          if (_isEnabled)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Quick Exit',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      'Try the Quick Exit feature to make sure it works as expected.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _testQuickExit,
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Test Quick Exit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Usage Statistics
          if (_isEnabled)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    _buildUsageStats(),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextButton(
                      onPressed: _clearUsageData,
                      child: const Text('Clear Usage Data'),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppConstants.spacingLarge),

          // Safety Information
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        'Safety Information',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    'Quick Exit is designed to help you quickly hide the app in situations where you need privacy or safety. The feature shows neutral content that doesn\'t reveal you were using a wellness app.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'If you\'re in immediate danger, please call emergency services using the contacts in the Emergency section.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    final stats = _quickExitService.getQuickExitUsageStats();

    if (stats.isEmpty) {
      return const Text('No Quick Exit usage recorded yet.');
    }

    return Column(
      children: stats.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getTriggerDisplayName(entry.key)),
              Text(
                '${entry.value} times',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getTriggerDisplayName(String trigger) {
    switch (trigger) {
      case 'button':
        return 'Quick Exit Button';
      case 'backPress':
        return 'Back Button';
      case 'shake':
        return 'Shake Device';
      case 'volumeKeys':
        return 'Volume Keys';
      default:
        return trigger;
    }
  }

  void _testQuickExit() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Quick Exit'),
        content: const Text(
          'This will activate the Quick Exit feature and show neutral content. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Test'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _quickExitService.logQuickExitUsage('test');
        final content = await _quickExitService.getQuickExitContent();

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuickExitScreen(
                content: content,
                onReturn: () => Navigator.pop(context),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error testing Quick Exit')),
          );
        }
      }
    }
  }

  void _clearUsageData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Usage Data'),
        content: const Text(
          'This will delete all Quick Exit usage statistics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _quickExitService.clearUsageData();
      setState(() {}); // Refresh to show cleared stats
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usage data cleared')));
      }
    }
  }
}
