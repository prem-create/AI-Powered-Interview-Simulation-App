import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/ui/mobile_ui/mobile_ui.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CameraInterview extends StatefulWidget {
  const CameraInterview({super.key});

  @override
  State<CameraInterview> createState() => _CameraInterviewState();
}

class _CameraInterviewState extends State<CameraInterview> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:(context) => CameraInterviewBloc(),
      child: ScreenTypeLayout.builder(mobile: (_) => MobileUi(),),
    );
  }
}
  