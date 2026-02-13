// ============================================================================
// NEXT BUTTON - Quiz Navigation Button Widget
// ============================================================================
// Reusable button for quiz navigation (Next/Finish)
// 
// FEATURES:
// - Customizable label text
// - Disabled state when onPressed is null
// - Visual feedback for enabled/disabled states
// - Full-width design for easy tapping
// 
// USAGE:
// - "Next" button: Enabled after answer selection
// - "Finish" button: Shown on last question
// 
// VISUAL STATES:
// - Enabled: White24 background, normal text
// - Disabled: Default background (darker), grayed appearance
// 
// TODO: Add loading state for async operations
// TODO: Add custom colors via parameters
// TODO: Add icon support
// ============================================================================

import 'package:flutter/material.dart';

/// Reusable rectangular button for quiz navigation
class RectangularButton extends StatelessWidget {
  const RectangularButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback? onPressed; // Callback when tapped (null = disabled)
  final String label; // Button text ("Next" or "Finish")

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: SizedBox(
        height: 50,
        width: double.infinity, // Full width for easy tapping
        child: Card(
          // Show white24 background when enabled, default when disabled
          color: onPressed != null ? Colors.white24 : null,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                letterSpacing: 2,
                fontSize: 25,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
