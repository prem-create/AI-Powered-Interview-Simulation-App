import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';

class MyCustomCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final Color buttoncolor;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed; // This is the function parameter

  const MyCustomCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttoncolor,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(10.w),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 350,
        decoration: BoxDecoration(
          color: backgroundColor, // Dynamic Color
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32), // Dynamic Icon
            16.ht,
            Text(
              title, // Dynamic Title
              style:  TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: Color(0xFF1A1A1A),
              ),
            ),
            24.ht,
            Text(
              description, // Dynamic Description
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            24.ht,
            SizedBox(
              width: double.infinity,
              height: 49.h,
              child: ElevatedButton(
                onPressed: onPressed, // Dynamic Function
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttoncolor,
                  //  const Color(0xFF3F51B5),
                  foregroundColor: Colors.white, //test color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
                child: Text(
                  buttonText, // Dynamic Button Text
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
