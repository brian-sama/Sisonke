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

class QuickExitScreen extends StatefulWidget {
  final Map<String, dynamic> content;
  final VoidCallback? onReturn;

  const QuickExitScreen({super.key, required this.content, this.onReturn});

  @override
  State<QuickExitScreen> createState() => _QuickExitScreenState();
}

class _QuickExitScreenState extends State<QuickExitScreen> {
  // --- Calculator state ---
  String _display = '0';
  double? _firstOperand;
  String? _pendingOp;
  bool _shouldReplace = false;

  // --- Notes state ---
  late List<Map<String, String>> _notes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final rawNotes = widget.content['notes'] as List? ?? [];
    _notes = rawNotes
        .map<Map<String, String>>((n) => {
              'title': n['title']?.toString() ?? '',
              'content': n['content']?.toString() ?? '',
              'date': n['date']?.toString() ?? '',
            })
        .toList();
    _controllers = _notes
        .map((n) => TextEditingController(text: n['content']))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Calculator logic ---
  void _onCalcButton(String label) {
    setState(() {
      if (label == 'C') {
        _display = '0';
        _firstOperand = null;
        _pendingOp = null;
        _shouldReplace = false;
        return;
      }
      if (label == '=') {
        if (_firstOperand != null && _pendingOp != null) {
          final second = double.tryParse(_display) ?? 0;
          double result;
          switch (_pendingOp) {
            case '+':
              result = _firstOperand! + second;
            case '-':
              result = _firstOperand! - second;
            case 'x':
              result = _firstOperand! * second;
            case '/':
              result = second == 0 ? 0 : _firstOperand! / second;
            default:
              result = second;
          }
          _display = result % 1 == 0
              ? result.toInt().toString()
              : result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
          _firstOperand = null;
          _pendingOp = null;
          _shouldReplace = true;
        }
        return;
      }
      if (label == '+' || label == '-' || label == 'x' || label == '/') {
        _firstOperand = double.tryParse(_display);
        _pendingOp = label;
        _shouldReplace = true;
        return;
      }
      if (label == '.') {
        if (_shouldReplace) {
          _display = '0.';
          _shouldReplace = false;
          return;
        }
        if (!_display.contains('.')) _display += '.';
        return;
      }
      // Digit
      if (_shouldReplace || _display == '0') {
        _display = label;
        _shouldReplace = false;
      } else if (_display.length < 10) {
        _display += label;
      }
    });
  }

  bool _isOperator(String s) =>
      s == '+' || s == '-' || s == 'x' || s == '/' || s == '=' || s == 'C';

  @override
  Widget build(BuildContext context) {
    final title = widget.content['title'] as String? ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(title.isEmpty ? '' : title),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: widget.onReturn ?? () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            onPressed: SystemNavigator.pop,
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _buildContent(title),
    );
  }

  Widget _buildContent(String title) {
    if (title == 'Calculator') return _buildCalculator();
    if (title == 'My Notes') return _buildNotes();
    return const SizedBox.expand();
  }

  // --- Functional calculator UI ---
  Widget _buildCalculator() {
    const rows = [
      ['C', '/', 'x', '-'],
      ['7', '8', '9', '+'],
      ['4', '5', '6', '='],
      ['1', '2', '3', '.'],
      ['0'],
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: Colors.grey[850],
          child: Text(
            _display,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w300,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: rows
                  .map(
                    (row) => Expanded(
                      child: Row(
                        children: row
                            .map(
                              (label) => Expanded(
                                flex: label == '0' ? 4 : 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: ElevatedButton(
                                    onPressed: () => _onCalcButton(label),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isOperator(label)
                                          ? Colors.orange
                                          : Colors.grey[200],
                                      foregroundColor: _isOperator(label)
                                          ? Colors.white
                                          : Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // --- Editable notes UI ---
  Widget _buildNotes() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _notes[index]['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _notes[index]['date'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllers[index],
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Write something…',
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (val) => _notes[index]['content'] = val,
                ),
              ],
            ),
          ),
        );
      },
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
