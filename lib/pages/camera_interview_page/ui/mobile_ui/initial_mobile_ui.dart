import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/my_icon_elevated_button.dart';

class InitialMobileUi extends StatelessWidget {
  InitialMobileUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Camera Interview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 234, 240, 249),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heroSize = _heroSizeForWidth(constraints.maxWidth);

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 16.w),
                      child: Center(
                        child: SizedBox(
                          width: heroSize,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/interview.webp',
                                    fit: BoxFit.cover,
                                  ),
                                  Center(
                                    child: MyIconElevatedButton(
                                      onPressed: () {
                                        context.read<CameraInterviewBloc>().add(
                                          AskInterviewDetailsEvent(),
                                        );
                                      },
                                      iconData: Icons.play_arrow_outlined,
                                      IconSize: 30,
                                      text: 'Start Interveiw',
                                      buttoncolor: const Color.fromARGB(
                                        255,
                                        60,
                                        92,
                                        221,
                                      ),
                                      textcolor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: SizedBox(
                              width: heroSize,
                              child: Text(
                                "Welcome to your mock interview! 🎯\n\nEnter your details to begin and give it your best shot! 🚀",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 50, 48, 48),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    10.ht,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _heroSizeForWidth(double width) {
    if (width >= 700) return 420;
    return width - 40.w;
  }
}
