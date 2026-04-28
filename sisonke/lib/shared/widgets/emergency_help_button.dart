import 'package:flutter/material.dart';

/// Floating Emergency Help Button
/// Available on all screens for quick access to emergency resources
class EmergencyHelpButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisible;

  const EmergencyHelpButton({
    super.key,
    required this.onPressed,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'emergency_help',
        elevation: 0,
        onPressed: onPressed,
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.sos_rounded),
        label: const Text(
          'Emergency help',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
