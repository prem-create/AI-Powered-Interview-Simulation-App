import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_app/core/constants/constants.dart';
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
    final firstQuestion = await _geminiRepository.sendToGemini();

    //if question is empty launch error state
    if (!firstQuestion.isSuccess) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage:
              firstQuestion.errorMessage ?? 'Unable to load question.',
        ),
      );
      return;
    }

    emit(CameraInterviewLoadingSuccessState(question: firstQuestion.data!));
  }

  // when user complete answering
  FutureOr<void> candidateAnswerSubmittedEvent(
    CandidateAnswerSubmittedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());

    if (event.isEndInterviewButtonTapped) {
      final result = await _geminiRepository.sendCandidateAnswer(event.answer);

      if (!result.isSuccess) {
        emit(
          CameraInterviewLoadingErrorState(
            errorMessage: result.errorMessage ?? 'Unable to generate result.',
          ),
        );
        return;
      }
      resultHistory.add(result.data!);
      emit(CameraInterviewResultState(result: result.data!));
    } else {
      final nextQuestion = await _geminiRepository.sendCandidateAnswer(
        event.answer,
      );

      if (!nextQuestion.isSuccess) {
        emit(
          CameraInterviewLoadingErrorState(
            errorMessage:
                nextQuestion.errorMessage ?? 'Unable to load next question.',
          ),
        );
        return;
      }

      emit(CameraInterviewLoadingSuccessState(question: nextQuestion.data!));
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
