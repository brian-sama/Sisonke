import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom AppBar for the app
class SisonkeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;
  final String? fallbackBackLocation;

  const SisonkeAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
    this.fallbackBackLocation,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack =
        showBackButton && (canPop || fallbackBackLocation != null);

    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading:
          leading ??
          (shouldShowBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      onBackPressed ??
                      () {
                        if (canPop) {
                          Navigator.of(context).maybePop();
                          return;
                        }
                        context.go(fallbackBackLocation!);
                      },
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
