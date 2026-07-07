import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/logic/speech_recording_logic.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/my_icon_elevated_button.dart';

class BottomBar extends StatefulWidget {
  BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> with WidgetsBindingObserver {
  final SpeechRecordingLogic record = SpeechRecordingLogic();
  bool isMicOn = false;
  bool isRecordingActionInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_shouldStopRecording(state)) {
      _cancelActiveRecording();
    }
  }

  bool _shouldStopRecording(AppLifecycleState state) {
    return state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached;
  }

  Future<void> _cancelActiveRecording() async {
    if (isMicOn && mounted) {
      setState(() => isMicOn = false);
    }
    await record.cancelRecording();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    record.dispose();
    super.dispose();
  }

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
              tooltip: isMicOn ? 'Stop recording' : 'Start recording',
              onPressed: isRecordingActionInProgress
                  ? null
                  : () async {
                      if (!isMicOn) {
                        await _startRecording();
                      } else {
                        await _stopRecordingAndSubmitAnswer();
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
              onPressed: () async {
                // Camera recording is not implemented yet.
              },
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

  Future<void> _startRecording() async {
    setState(() => isRecordingActionInProgress = true);

    final result = await record.startRecording();
    if (!mounted) return;

    setState(() {
      isMicOn = result.isSuccess;
      isRecordingActionInProgress = false;
    });

    if (!result.isSuccess) {
      _showRecordingStartFailure(result.failure);
    }
  }

  Future<void> _stopRecordingAndSubmitAnswer() async {
    setState(() {
      isMicOn = false;
      isRecordingActionInProgress = true;
    });

    final cameraInterviewBloc = context.read<CameraInterviewBloc>();
    final audioFile = await record.stopRecordingToFile();

    if (audioFile == null) {
      if (mounted) {
        setState(() => isRecordingActionInProgress = false);
      }
      return;
    }

    cameraInterviewBloc.add(CandidateAnswerTranscriptionStartedEvent());

    final transcriptionResult = await record.transcribeRecording(audioFile);

    if (!cameraInterviewBloc.isClosed && !transcriptionResult.isSuccess) {
      cameraInterviewBloc.add(
        CandidateAnswerTranscriptionFailedEvent(
          errorMessage: transcriptionResult.errorMessage!,
        ),
      );
    } else if (transcriptionResult.transcript != null) {
      userTranscription = transcriptionResult.transcript!;
      if (!cameraInterviewBloc.isClosed) {
        cameraInterviewBloc.add(
          CandidateAnswerSubmittedEvent(
            answer: transcriptionResult.transcript!,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => isRecordingActionInProgress = false);
    }
  }

  void _showRecordingStartFailure(RecordingStartFailure? failure) {
    final message = switch (failure) {
      RecordingStartFailure.permissionDenied =>
        'Microphone permission is required to record your answer.',
      RecordingStartFailure.unavailable ||
      null => 'Could not start recording. Please try again.',
    };

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
