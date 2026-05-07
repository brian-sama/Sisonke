import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometricTrigger;
  final bool showBiometricButton;
  final IconData? biometricIcon;

  const PinKeypad({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
    this.onBiometricTrigger,
    this.showBiometricButton = false,
    this.biometricIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> keyLabels = [
      {'num': '1', 'letters': ''},
      {'num': '2', 'letters': 'A B C'},
      {'num': '3', 'letters': 'D E F'},
      {'num': '4', 'letters': 'G H I'},
      {'num': '5', 'letters': 'J K L'},
      {'num': '6', 'letters': 'M N O'},
      {'num': '7', 'letters': 'P Q R S'},
      {'num': '8', 'letters': 'T U V'},
      {'num': '9', 'letters': 'W X Y Z'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int row = 0; row < 3; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int col = 0; col < 3; col++)
                _buildNumberButton(
                  context,
                  keyLabels[row * 3 + col]['num']!,
                  keyLabels[row * 3 + col]['letters']!,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Biometrics Trigger Button
            SizedBox(
              width: 72,
              height: 72,
              child: showBiometricButton && onBiometricTrigger != null
                  ? IconButton(
                      icon: Icon(
                        biometricIcon ?? Icons.fingerprint_rounded,
                        size: 30,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: onBiometricTrigger,
                      tooltip: 'Unlock using biometrics',
                    )
                  : const SizedBox.shrink(),
            ),
            // Zero button
            _buildNumberButton(context, '0', ''),
            // Backspace Button
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                icon: Icon(
                  Icons.backspace_outlined,
                  size: 24,
                  color: isDark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: onBackspace,
                tooltip: 'Backspace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, String number, String letters) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final btnBg = isDark
        ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.8)
        : theme.colorScheme.surfaceContainerLow;

    final inkColor = theme.colorScheme.primary.withValues(alpha: 0.12);

    return Material(
      color: btnBg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1.5,
      shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => onKeyPress(number),
        splashColor: inkColor,
        highlightColor: inkColor,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  fontSize: 26,
                  height: 1.1,
                ),
              ),
              if (letters.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  letters,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
