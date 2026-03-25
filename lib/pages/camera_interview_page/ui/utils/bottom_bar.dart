import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/logic/speech_recording_logic.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/my_icon_elevated_button.dart';

class BottomBar extends StatefulWidget {
  BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final SpeechRecordingLogic record = SpeechRecordingLogic();
  bool isMicOn = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Row(
        children: [
          20.wt,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: IconButton(
              onPressed: () async {
                if (!isMicOn) {
                  // START recording
                  setState(() {
                    isMicOn = true;
                  });

                  await record.startRecording();
                } else {
                  // STOP recording
                  setState(() {
                    isMicOn = false;
                  });

                  final transcript = await record.stopRecording(); // ✅ await

                  if (transcript != null) {
                    context.read<CameraInterviewBloc>().add(
                      CandidateAnswerSubmittedEvent(answer: transcript),
                    );
                  }
                }
              },
              icon: Icon(isMicOn ? Icons.mic : Icons.mic_off, size: 35.sp),
            ),
          ),
          20.wt,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.videocam_off, size: 35.sp),
            ),
          ),
          20.wt,
          //End Interview Button
          MyIconElevatedButton(
            onPressed: () {
              final String answer = 'End Interview';
              context.read<CameraInterviewBloc>().add(
                CandidateAnswerSubmittedEvent(
                  answer: answer,
                  isEndInterviewButtonTapped: true,
                ),
              );
            },
            iconData: Icons.cancel_sharp,
            IconSize: 20.sp,
            text: 'End Session',
            buttoncolor: Colors.red,
            textcolor: Colors.white,
          ),
        ],
      ),
    );
  }
}
