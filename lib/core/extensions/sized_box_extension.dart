// ============================================================================
// SIZED BOX EXTENSION - Responsive Spacing Utility
// ============================================================================
// Extension methods for creating responsive spacing widgets
// 
// FEATURES:
// - .ht: Creates SizedBox with responsive height
// - .wt: Creates SizedBox with responsive width
// - Uses flutter_screenutil for automatic scaling across devices
// 
// USAGE EXAMPLES:
// - 20.ht → SizedBox with height 20 (scaled)
// - 50.wt → SizedBox with width 50 (scaled)
// - Replaces: SizedBox(height: 20.h) with cleaner syntax
// 
// BENEFITS:
// - Cleaner, more readable code
// - Automatic responsive scaling
// - Consistent spacing across different screen sizes
// 
// TODO: Add more spacing utilities:
// - Padding extensions
// - Margin extensions
// - Gap widgets for Flex layouts
// ============================================================================

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension on num to create responsive SizedBox widgets
extension SizedBoxExtension on num? {
  // num validate({int value = 0}) {
  //   return this ?? value;
  // }

  /// Creates a SizedBox with responsive height
  /// Example: 20.ht → SizedBox(height: 20.h)
  Widget get ht {
    return SizedBox(height: this!.h);
  }

  /// Creates a SizedBox with responsive width
  /// Example: 50.wt → SizedBox(width: 50.w)
  Widget get wt {
    return SizedBox(width: this!.w);
  }
}
