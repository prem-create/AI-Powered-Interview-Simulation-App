import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/my_icon_elevated_button.dart';

class InitialMobileUi extends StatelessWidget {
  InitialMobileUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: Center(
          child: Text(
            'Camera Interview',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 234, 240, 249),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,

                child: Stack(
                  children: [
                    Padding(
                      padding:  EdgeInsets.all(20.w),
                      child: Container(
                        width: double.infinity,
                        // height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/interview.webp'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: MyIconElevatedButton(
                            onPressed: () {
                              context.read<CameraInterviewBloc>().add(
                                AskInterviewDetailsEvent(),
                              );
                            },
                            iconData: Icons.play_arrow_outlined,
                            IconSize: 30,
                            text: 'Start Interveiw',
                            buttoncolor: const Color.fromARGB(255, 60, 92, 221),
                            textcolor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:  EdgeInsets.only(left: 20.w, right: 20.w),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding:  EdgeInsets.all(15.w),
                        child: Text(
                          "Welcome to your mock interview! 🎯\n\nEnter your details to begin and give it your best shot! 🚀",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 50, 48, 48),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.ht,
            ],
          ),
        ),
      ),
    );
  }
}
