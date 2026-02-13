// ============================================================================
// CAMERA INTERVIEW PAGE - AI-Powered Voice Interview
// ============================================================================
// Main interview feature with AI-driven questions and voice interaction
// 
// FEATURES:
// 1. Text-to-Speech (TTS) - AI speaks questions aloud
// 2. Speech-to-Text (STT) - User responds verbally (planned)
// 3. Real-time AI evaluation using Gemini API
// 4. Contextual follow-up questions based on answers
// 5. Comprehensive performance report at the end
// 
// FLOW:
// 1. User enters interview details (name, topic, difficulty)
// 2. AI asks first question and speaks it aloud
// 3. User provides answer (text input, voice planned)
// 4. AI evaluates and asks follow-up question
// 5. Repeat until user ends interview
// 6. AI generates detailed performance report
// 
// TODO: Implement actual camera/video recording for body language analysis
// TODO: Add speech-to-text for voice input instead of text typing
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/ui/mobile_ui/mobile_ui.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// Camera Interview page - AI-powered interview with voice interaction
class CameraInterview extends StatefulWidget {
  const CameraInterview({super.key});

  @override
  State<CameraInterview> createState() => _CameraInterviewState();
}

class _CameraInterviewState extends State<CameraInterview> {
  @override
  Widget build(BuildContext context) {
    // Provide CameraInterviewBloc to manage interview state
    return BlocProvider(
      create:(context) => CameraInterviewBloc(),
      // Responsive layout - currently only mobile UI implemented
      // TODO: Add desktop and tablet layouts for better multi-device support
      child: ScreenTypeLayout.builder(mobile: (_) => MobileUi(),),
    );
  }
}
  