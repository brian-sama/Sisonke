import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class QuickExitButton extends StatefulWidget {
  final VoidCallback? onExit;
  final bool showTooltip;
  final double? size;
  final Color? color;

  const QuickExitButton({
    super.key,
    this.onExit,
    this.showTooltip = true,
    this.size,
    this.color,
  });

  @override
  State<QuickExitButton> createState() => _QuickExitButtonState();
}

class _QuickExitButtonState extends State<QuickExitButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return widget.showTooltip
        ? Tooltip(
            message: 'Quick Exit - Press to leave app quickly',
            child: _buildButton(),
          )
        : _buildButton();
  }

  Widget _buildButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleQuickExit();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppConstants.animationShort,
        width: widget.size ?? 50,
        height: widget.size ?? 50,
        decoration: BoxDecoration(
          color: widget.color ?? Colors.red,
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(
          Icons.exit_to_app,
          color: Colors.white,
          size: (widget.size ?? 50) * 0.5,
        ),
      ),
    );
  }

  void _handleQuickExit() {
    HapticFeedback.lightImpact();
    widget.onExit?.call();
  }
}

class QuickExitFloatingButton extends StatelessWidget {
  final VoidCallback? onExit;
  final Alignment alignment;

  const QuickExitFloatingButton({
    super.key,
    this.onExit,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: QuickExitButton(onExit: onExit, size: 40),
    );
  }
}

class QuickExitAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onExit;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const QuickExitAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onExit,
    this.automaticallyImplyLeading = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: [
        if (onExit != null)
          QuickExitButton(onExit: onExit, size: 36, showTooltip: false),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }
}

class QuickExitDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onExit;
  final bool enableBackPress;
  final bool enableVolumeKeys;

  const QuickExitDetector({
    super.key,
    required this.child,
    this.onExit,
    this.enableBackPress = true,
    this.enableVolumeKeys = false,
  });

  @override
  State<QuickExitDetector> createState() => _QuickExitDetectorState();
}

class _QuickExitDetectorState extends State<QuickExitDetector>
    with WidgetsBindingObserver {
  DateTime? _lastBackPressTime;
  int _volumeKeyPressCount = 0;
  DateTime? _volumeKeyStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enableVolumeKeys) {
      HardwareVolumeButtons.setVolumeButtonStreamEnabled(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.enableVolumeKeys) {
      HardwareVolumeButtons.setVolumeButtonStreamEnabled(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.enableBackPress) {
          await _handleWillPop();
        }
      },
      child: widget.enableVolumeKeys
          ? HardwareVolumeButtons(
              onVolumeButtonPressed: _handleVolumeButtonPressed,
              child: widget.child,
            )
          : widget.child,
    );
  }

  Future<bool> _handleWillPop() async {
    final now = DateTime.now();

    // Check if back button was pressed twice within 2 seconds
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!).inSeconds < 2) {
      widget.onExit?.call();
      return false; // Don't actually pop
    }

    _lastBackPressTime = now;

    // Show snackbar on first back press
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Press back again to Quick Exit'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    return false; // Don't pop yet
  }

  void _handleVolumeButtonPressed(VolumeButton button) {
    final now = DateTime.now();

    // Reset counter if more than 2 seconds have passed
    if (_volumeKeyStartTime == null ||
        now.difference(_volumeKeyStartTime!).inSeconds > 2) {
      _volumeKeyPressCount = 0;
      _volumeKeyStartTime = now;
    }

    _volumeKeyPressCount++;

    // Trigger Quick Exit if volume keys pressed 3+ times
    if (_volumeKeyPressCount >= 3) {
      widget.onExit?.call();
      _volumeKeyPressCount = 0;
    }

    // Show feedback after 2 presses
    if (_volumeKeyPressCount == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('One more volume press to Quick Exit'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class QuickExitScreen extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback? onReturn;

  const QuickExitScreen({super.key, required this.content, this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(content['title'] ?? 'Quick Exit'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: onReturn ?? () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Return to Sisonke',
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Close app completely
              SystemNavigator.pop();
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close App',
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final title = content['title'] as String? ?? '';

    if (title == 'Calculator') {
      return _buildCalculatorContent();
    } else if (title == 'My Notes') {
      return _buildNotesContent();
    }

    return const SizedBox.expand();
  }

  Widget _buildCalculatorContent() {
    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Calculator\n(Tap to use)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: (content['notes'] as List).length,
        itemBuilder: (context, index) {
          final note = (content['notes'] as List)[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(note['content'], style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    note['date'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Hardware volume button listener (simplified version)
class HardwareVolumeButtons extends StatefulWidget {
  final Function(VolumeButton)? onVolumeButtonPressed;
  final Widget child;

  const HardwareVolumeButtons({
    super.key,
    this.onVolumeButtonPressed,
    required this.child,
  });

  static void setVolumeButtonStreamEnabled(bool enabled) {
    // This would need platform-specific implementation
    // For now, it's a placeholder
  }

  @override
  State<HardwareVolumeButtons> createState() => _HardwareVolumeButtonsState();
}

class _HardwareVolumeButtonsState extends State<HardwareVolumeButtons> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

enum VolumeButton { volumeUp, volumeDown }
