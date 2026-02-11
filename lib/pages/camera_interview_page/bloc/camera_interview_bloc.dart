import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_app/pages/camera_interview_page/logic/tts_logic.dart';
import 'package:interview_app/pages/camera_interview_page/repo/gemini_repo.dart';

import 'package:meta/meta.dart';
part 'camera_interview_event.dart';
part 'camera_interview_state.dart';

class CameraInterviewBloc
    extends Bloc<CameraInterviewEvent, CameraInterviewState> {
  final GeminiRepository _geminiRepository = GeminiRepository();

  CameraInterviewBloc() : super(CameraInterviewInitial()) {
    on<CameraInterviewInitialEvent>(cameraInterviewInitialEvent);
    on<StartCameraInterviewButtonTappedEvent>(
      startCameraInterviewButtonTappedEvent,
    );
    on<CandidateAnswerSubmittedEvent>(candidateAnswerSubmittedEvent);
    on<AskInterviewDetailsEvent>(askInterviewDetailsEvent);
    on<SpeakTtsEvent>(speakTtsEvent);
  }

  FutureOr<void> startCameraInterviewButtonTappedEvent(
    StartCameraInterviewButtonTappedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());
    // STEP 1: Initialize interview
    _geminiRepository.startInterview(
      InterviewTopic: event.InterviewTopic,
      candidateName: event.candidateName,
      difficultyLevel: event.difficultyLevel,
    );

    // STEP 2: Ask first question
    final String? firstQuestion = await _geminiRepository.sendToGemini();

    if (firstQuestion == null) {
      emit(CameraInterviewLoadingErrorState());
      return;
    }

    emit(CameraInterviewLoadingSuccessState(question: firstQuestion));
  }

  FutureOr<void> cameraInterviewInitialEvent(
    CameraInterviewInitialEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(CameraInterviewInitial());
  }

  FutureOr<void> candidateAnswerSubmittedEvent(
    CandidateAnswerSubmittedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());

    if (event.isEndInterviewButtonTapped) {
      final String? nextQuestion = await _geminiRepository.sendCandidateAnswer(
        event.answer,
      );

      if (nextQuestion == null) {
        emit(CameraInterviewLoadingErrorState());
        return;
      }

      emit(CameraInterviewResultState(result: nextQuestion));
    } else {
      final String? nextQuestion = await _geminiRepository.sendCandidateAnswer(
        event.answer,
      );

      if (nextQuestion == null) {
        emit(CameraInterviewLoadingErrorState());
        return;
      }

      emit(CameraInterviewLoadingSuccessState(question: nextQuestion));
    }
  }

  FutureOr<void> askInterviewDetailsEvent(
    AskInterviewDetailsEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(AskInterviewDetailsState());
  }

  FutureOr<void> speakTtsEvent(
    SpeakTtsEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    TtsLogic ttsLogic = TtsLogic();
    //initalize
    ttsLogic.initializeTts();
    //speak
    ttsLogic.speak(text: event.text);
  }
}
