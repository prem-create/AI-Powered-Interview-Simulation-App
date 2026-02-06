import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SizedBoxExtension on num? {
  // num validate({int value = 0}) {
  //   return this ?? value;
  // }

  Widget get ht {
    return SizedBox(height: this!.h);
  }

  Widget get wt {
    return SizedBox(width: this!.w);
  }
}
