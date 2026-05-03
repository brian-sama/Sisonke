import 'package:flutter/material.dart';

/// Custom button styles and widgets
class SisonkeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonType buttonType;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsets padding;
  final bool isFullWidth;

  const SisonkeButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.buttonType = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button;
    Widget buttonContent = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    switch (buttonType) {
      case ButtonType.primary:
        button = FilledButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: FilledButton.styleFrom(
            padding: padding,
          ),
          child: buttonContent,
        );
        break;

      case ButtonType.secondary:
        button = FilledButton.tonal(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: FilledButton.styleFrom(padding: padding),
          child: buttonContent,
        );
        break;

      case ButtonType.text:
        button = TextButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: TextButton.styleFrom(
            padding: padding,
          ),
          child: buttonContent,
        );
        break;

      case ButtonType.danger:
        button = FilledButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: FilledButton.styleFrom(
            padding: padding,
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: buttonContent,
        );
        break;
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum ButtonType {
  primary,
  secondary,
  text,
  danger,
}

