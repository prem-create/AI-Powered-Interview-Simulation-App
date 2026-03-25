import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_app/pages/camera_interview_page/logic/tts_logic.dart';
import 'package:interview_app/pages/camera_interview_page/repo/gemini_repo.dart';
import 'package:interview_app/pages/camera_interview_page/services/gemini_api_service.dart';
import 'package:meta/meta.dart';

part 'camera_interview_event.dart';
part 'camera_interview_state.dart';

class CameraInterviewBloc
    extends Bloc<CameraInterviewEvent, CameraInterviewState> {
  final GeminiRepository _geminiRepository = GeminiRepository(
    GeminiApiService(),
  );
  CameraInterviewBloc() : super(CameraInterviewInitial()) {
    //camera initaial->action state->launch inital mobile ui
    on<CameraInterviewInitialEvent>(cameraInterviewInitialEvent);

    //Start Interview button tapped
    on<AskInterviewDetailsEvent>(askInterviewDetailsEvent);

    //proceed button tapped
    on<StartCameraInterviewButtonTappedEvent>(
      startCameraInterviewButtonTappedEvent,
    );

    //Candidate stopped speaking 
    on<CandidateAnswerSubmittedEvent>(candidateAnswerSubmittedEvent);

    on<SpeakTtsEvent>(speakTtsEvent);
  }

  // camera interview button tapped
  FutureOr<void> cameraInterviewInitialEvent(
    CameraInterviewInitialEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(CameraInterviewInitial());
  }

  // start interview button tapped
  FutureOr<void> askInterviewDetailsEvent(
    AskInterviewDetailsEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(AskInterviewDetailsState());
  }

  //proceed button tapped
  FutureOr<void> startCameraInterviewButtonTappedEvent(
    StartCameraInterviewButtonTappedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());
    //make first json body which has instructions and candidate details
    _geminiRepository.startInterview(
      interviewTopic: event.InterviewTopic,
      candidateName: event.candidateName,
      difficultyLevel: event.difficultyLevel,
    );

    //sendToGemini will make a api call using the json body we created above
    final String? firstQuestion = await _geminiRepository.sendToGemini()??'testing';

//if question is empty launch error state
    if (firstQuestion == null) {
      emit(CameraInterviewLoadingErrorState());
      return;
    }

    emit(CameraInterviewLoadingSuccessState(question: firstQuestion));
  }

 // when user complete answering
  FutureOr<void> candidateAnswerSubmittedEvent(
    CandidateAnswerSubmittedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());

    if (event.isEndInterviewButtonTapped) {
      final String? result = await _geminiRepository.sendCandidateAnswer(
        event.answer,
      );

      if (result == null) {
        emit(CameraInterviewLoadingErrorState());
        return;
      }

      emit(CameraInterviewResultState(result: result));
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

  FutureOr<void> speakTtsEvent(
    SpeakTtsEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    TtsLogic ttsLogic = TtsLogic();
    ttsLogic.initializeTts();
    ttsLogic.speak(text: event.text);
  }
}
