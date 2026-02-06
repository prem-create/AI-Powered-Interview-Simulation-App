import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,

              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
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
                    ),
                  ),
                  Center(
                    child: MyIconElevatedButton(
                      onPressed: () {context.read<CameraInterviewBloc>().add(AskInterviewDetailsEvent());},
                      iconData: Icons.play_arrow_outlined,
                      IconSize: 35,
                      text: 'Start Interveiw',
                      buttoncolor: const Color.fromARGB(255, 60, 92, 221),
                      textcolor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AI Prompt",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            10.ht,
                            Text(
                              'Welcome to your camera interview. Interview Question form AI will be displayed here',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 50, 48, 48),
                                fontSize: 20,
                              ),
                            ),
                          ],
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
    );
  }
}
