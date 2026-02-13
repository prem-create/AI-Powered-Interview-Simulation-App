// ============================================================================
// MY ELEVATED BUTTON - Reusable Custom Button Widget
// ============================================================================
// Custom elevated button with consistent styling across the app
// 
// FEATURES:
// - Customizable text, colors, and action
// - Responsive sizing using flutter_screenutil
// - Consistent styling with bold white text
// 
// PARAMETERS:
// - text: Button label
// - onPressed: Callback when button is tapped
// - buttoncolor: Background color
// - buttontextcolor: Text color (though currently overridden to white)
// 
// USAGE:
// Used throughout the app for primary action buttons
// 
// TODO: Fix text color - currently hardcoded to white, ignoring buttontextcolor
// TODO: Add loading state support
// TODO: Add icon support (commented out)
// TODO: Make size customizable instead of fixed 50x40
// TODO: Add disabled state styling
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/// Reusable custom elevated button widget
class MyElevatedButton extends StatelessWidget {
  final String text; // Button label text
  final Color buttoncolor; // Background color
  final Color buttontextcolor; // Text color (currently not used)
  final VoidCallback onPressed; // Tap callback
  // final IconData icon; // TODO: Add icon support

  const MyElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.buttoncolor,
    required this.buttontextcolor,
    // required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w, // Responsive width
      height: 40.h, // Responsive height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          foregroundColor: buttontextcolor,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white, // TODO: Use buttontextcolor parameter instead
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
