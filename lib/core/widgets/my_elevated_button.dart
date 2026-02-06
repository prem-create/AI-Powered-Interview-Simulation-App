import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MyElevatedButton extends StatelessWidget {
  final String text;
  final Color buttoncolor;
  final Color buttontextcolor;
  final VoidCallback onPressed;
  // final IconData icon;

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
      width: 50.w,
      height: 40.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          foregroundColor: buttontextcolor,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
