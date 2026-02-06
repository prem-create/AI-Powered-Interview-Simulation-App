import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyIconElevatedButton extends StatelessWidget {
  final IconData iconData;
  final double IconSize;
  final String text;
  final Color buttoncolor;
  final Color textcolor;
  final VoidCallback onPressed;

  const MyIconElevatedButton({
    required this.iconData,
    required this.IconSize,
    required this.text,
    required this.buttoncolor,
    required this.textcolor,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(iconData, size: IconSize),
        label: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp.clamp(14, 24),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          foregroundColor: textcolor,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
