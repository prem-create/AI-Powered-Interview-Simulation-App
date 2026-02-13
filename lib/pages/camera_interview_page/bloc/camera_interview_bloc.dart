// ============================================================================
// CAMERA INTERVIEW BLOC - Interview Session Management
// ============================================================================
// Core business logic for AI-powered interview feature
// 
// RESPONSIBILITIES:
// 1. Initialize interview session with user details
// 2. Communicate with Gemini AI for questions and evaluation
// 3. Manage interview conversation flow
// 4. Handle text-to-speech for AI questions
// 5. Generate final performance report
// 
// INTERVIEW FLOW:
// 1. StartCameraInterviewButtonTappedEvent → Initialize + Get first question
// 2. CandidateAnswerSubmittedEvent → Send answer + Get next question
// 3. Repeat step 2 until user ends interview
// 4. Generate comprehensive feedback report
// 
// AI INTEGRATION:
// - Uses GeminiRepository for API communication
// - Maintains conversation context for intelligent follow-ups
// - Prompt engineering ensures professional interviewer behavior
// ============================================================================

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_app/pages/camera_interview_page/logic/tts_logic.dart';
import 'package:interview_app/pages/camera_interview_page/repo/gemini_repo.dart';

import 'package:meta/meta.dart';
part 'camera_interview_event.dart';
part 'camera_interview_state.dart';

/// CameraInterviewBloc: Manages interview session state and AI interaction
class CameraInterviewBloc
    extends Bloc<CameraInterviewEvent, CameraInterviewState> {
  // Repository for Gemini AI communication
  final GeminiRepository _geminiRepository = GeminiRepository();

  CameraInterviewBloc() : super(CameraInterviewInitial()) {
    // Register event handlers
    on<CameraInterviewInitialEvent>(cameraInterviewInitialEvent);
    on<StartCameraInterviewButtonTappedEvent>(
      startCameraInterviewButtonTappedEvent,
    );
    on<CandidateAnswerSubmittedEvent>(candidateAnswerSubmittedEvent);
    on<AskInterviewDetailsEvent>(askInterviewDetailsEvent);
    on<SpeakTtsEvent>(speakTtsEvent);
  }

  /// Handles interview start event
  /// FLOW:
  /// 1. Show loading state
  /// 2. Initialize interview with user details (name, topic, difficulty)
  /// 3. Request first question from Gemini AI
  /// 4. Emit success state with question or error state if failed
  FutureOr<void> startCameraInterviewButtonTappedEvent(
    StartCameraInterviewButtonTappedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());
    
    // STEP 1: Initialize interview session with prompt engineering
    // Sets up AI as professional interviewer with specific instructions
    _geminiRepository.startInterview(
      InterviewTopic: event.InterviewTopic,
      candidateName: event.candidateName,
      difficultyLevel: event.difficultyLevel,
    );

    // STEP 2: Request first question from AI
    final String? firstQuestion = await _geminiRepository.sendToGemini();

    // Handle error if AI doesn't respond
    if (firstQuestion == null) {
      emit(CameraInterviewLoadingErrorState());
      return;
    }

    // Emit success with first question - UI will display and speak it
    emit(CameraInterviewLoadingSuccessState(question: firstQuestion));
  }

  /// Returns to initial state (interview details form)
  FutureOr<void> cameraInterviewInitialEvent(
    CameraInterviewInitialEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(CameraInterviewInitial());
  }

  /// Handles candidate answer submission
  /// FLOW:
  /// 1. Stop any ongoing TTS speech
  /// 2. Send answer to Gemini AI
  /// 3. If "End Interview" → Generate final report
  /// 4. Otherwise → Get next question and continue
  FutureOr<void> candidateAnswerSubmittedEvent(
    CandidateAnswerSubmittedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    TtsLogic tts = TtsLogic();
    emit(CameraInterviewLoadingState());
    
    // Stop speaking previous question before processing answer
    tts.stopSpeaking();
    

    // Check if user wants to end the interview
    if (event.isEndInterviewButtonTapped) {
      // Send final answer and request comprehensive evaluation report
      final String? result = await _geminiRepository.sendCandidateAnswer(
        event.answer,
      );

      if (result == null) {
        emit(CameraInterviewLoadingErrorState());
        return;
      }

      // Emit result state with performance report
      emit(CameraInterviewResultState(result: result));
    } else {
      // Continue interview - send answer and get next question
      final String? nextQuestion = await _geminiRepository.sendCandidateAnswer(
        event.answer,
      );

      if (nextQuestion == null) {
        emit(CameraInterviewLoadingErrorState());
        return;
      }

      // Emit success with next question
      emit(CameraInterviewLoadingSuccessState(question: nextQuestion));
    }
  }

  /// Returns to interview details form
  /// Allows user to restart or modify interview parameters
  FutureOr<void> askInterviewDetailsEvent(
    AskInterviewDetailsEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(AskInterviewDetailsState());
  }

  /// Handles text-to-speech for AI questions
  /// Speaks the question aloud for better interview simulation
  /// TODO: Add voice customization options (speed, pitch, language)
  FutureOr<void> speakTtsEvent(
    SpeakTtsEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    TtsLogic ttsLogic = TtsLogic();
    // Initialize TTS engine
    ttsLogic.initializeTts();
    // Speak the provided text (AI question)
    ttsLogic.speak(text: event.text);
  }
}
