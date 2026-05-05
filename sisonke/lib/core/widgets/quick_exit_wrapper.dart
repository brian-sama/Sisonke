import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quick_exit_service.dart';
import '../providers/app_providers.dart';
import 'quick_exit_button.dart';

class QuickExitWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String? currentRoute;
  final bool forceShow;
  final QuickExitOptions? options;

  const QuickExitWrapper({
    super.key,
    required this.child,
    this.currentRoute,
    this.forceShow = false,
    this.options,
  });

  @override
  ConsumerState<QuickExitWrapper> createState() => _QuickExitWrapperState();
}

class _QuickExitWrapperState extends ConsumerState<QuickExitWrapper> {
  late QuickExitService _quickExitService;
  bool _showQuickExit = false;
  QuickExitOptions _options = const QuickExitOptions();

  @override
  void initState() {
    super.initState();
    _initializeQuickExit();
  }

  void _initializeQuickExit() {
    final prefs = ref.read(sharedPreferencesProvider);
    _quickExitService = QuickExitService(prefs);
    _options = widget.options ?? const QuickExitOptions();

    // Check if Quick Exit should be shown
    _updateQuickExitVisibility();
  }

  void _updateQuickExitVisibility() {
    final route =
        widget.currentRoute ?? ModalRoute.of(context)?.settings.name ?? '';
    _showQuickExit =
        widget.forceShow || _quickExitService.shouldShowQuickExit(route);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showQuickExit) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_options.showFloatingButton)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: QuickExitButton(onExit: _handleQuickExit, size: 40),
          ),
        if (_options.showAppBarButton) _buildAppBarWithQuickExit(),
        if (_options.enableBackPress || _options.enableVolumeKeys)
          QuickExitDetector(
            onExit: _handleQuickExit,
            enableBackPress: _options.enableBackPress,
            enableVolumeKeys: _options.enableVolumeKeys,
            child: widget.child,
          ),
      ],
    );
  }

  Widget _buildAppBarWithQuickExit() {
    // This would need to be integrated with the existing AppBar
    // For now, we'll use a floating action button as fallback
    return const SizedBox.shrink();
  }

  Future<void> _handleQuickExit() async {
    try {
      // Log usage
      await _quickExitService.logQuickExitUsage('button');

      // Get Quick Exit content
      final content = await _quickExitService.getQuickExitContent();

      // Navigate to Quick Exit screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuickExitScreen(
              content: content,
              onReturn: () {
                Navigator.of(context).pop();
                if (_options.onReturn != null) {
                  _options.onReturn!();
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Fallback: just minimize app
      if (mounted) {
        SystemNavigator.pop();
      }
    }
  }
}

class QuickExitOptions {
  final bool showFloatingButton;
  final bool showAppBarButton;
  final bool enableBackPress;
  final bool enableVolumeKeys;
  final VoidCallback? onReturn;

  const QuickExitOptions({
    this.showFloatingButton = true,
    this.showAppBarButton = false,
    this.enableBackPress = false,
    this.enableVolumeKeys = false,
    this.onReturn,
  });
}

// Extension methods for easy Quick Exit integration
extension QuickExitScreenExtension on Widget {
  Widget withQuickExit({
    String? currentRoute,
    bool forceShow = false,
    QuickExitOptions? options,
  }) {
    return QuickExitWrapper(
      currentRoute: currentRoute,
      forceShow: forceShow,
      options: options,
      child: this,
    );
  }
}

// Scaffold extension for Quick Exit AppBar
extension QuickExitScaffoldExtension on Scaffold {
  Scaffold withQuickExitAppBar({
    required String title,
    List<Widget>? actions,
    VoidCallback? onQuickExit,
  }) {
    return this;
  }
}

// Pre-configured Quick Exit options for different screen types
class QuickExitPresets {
  static const QuickExitOptions sensitive = QuickExitOptions(
    showFloatingButton: true,
    enableBackPress: false,
    enableVolumeKeys: false,
  );

  static const QuickExitOptions emergency = QuickExitOptions(
    showFloatingButton: true,
    enableBackPress: false,
    enableVolumeKeys: true,
  );

  static const QuickExitOptions minimal = QuickExitOptions(
    showFloatingButton: false,
    enableBackPress: false,
    enableVolumeKeys: false,
  );

  static const QuickExitOptions comprehensive = QuickExitOptions(
    showFloatingButton: true,
    showAppBarButton: true,
    enableBackPress: false,
    enableVolumeKeys: true,
  );
}
