import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/pages/camera_interview_page/logic/tts_logic.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_persistence_exception.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_session_details.dart';
import 'package:interview_app/pages/camera_interview_page/repo/gemini_repo.dart';
import 'package:interview_app/pages/camera_interview_page/repo/interview_persistence_repository.dart';
import 'package:interview_app/pages/camera_interview_page/services/gemini_api_service.dart';
import 'package:meta/meta.dart';

part 'camera_interview_event.dart';
part 'camera_interview_state.dart';

class CameraInterviewBloc
    extends Bloc<CameraInterviewEvent, CameraInterviewState> {
  CameraInterviewBloc({
    GeminiRepository? geminiRepository,
    InterviewPersistenceRepository? interviewPersistenceRepository,
  }) : _geminiRepository =
           geminiRepository ?? GeminiRepository(GeminiApiService()),
       _interviewPersistenceRepository =
           interviewPersistenceRepository ?? InterviewPersistenceRepository(),
       super(CameraInterviewInitial()) {
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

  final GeminiRepository _geminiRepository;
  final InterviewPersistenceRepository _interviewPersistenceRepository;
  String? _activeInterviewId;

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
    final interviewDetails = InterviewSessionDetails(
      candidateName: event.candidateName,
      interviewTopic: event.InterviewTopic,
      difficultyLevel: event.difficultyLevel,
      interviewType: event.interviewType,
      yearsOfExperience: event.yearsOfExperience,
    );

    try {
      _activeInterviewId = await _interviewPersistenceRepository
          .createInterviewSession(interviewDetails);
    } on InterviewPersistenceException catch (error) {
      emit(CameraInterviewLoadingErrorState(errorMessage: error.message));
      return;
    } catch (_) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'Could not save interview details. Please try again.',
        ),
      );
      return;
    }

    //make first json body which has instructions and candidate details
    _geminiRepository.startInterview(
      interviewTopic: event.InterviewTopic,
      candidateName: event.candidateName,
      difficultyLevel: event.difficultyLevel,
      interviewType: event.interviewType,
      yearsOfExperience: event.yearsOfExperience,
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
      await _generateAndSaveResult(emit);
    } else {
      final nextQuestion = await _geminiRepository.submitCandidateAnswer(
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

      final turnResponse = nextQuestion.data!;
      if (turnResponse.shouldGenerateResult) {
        await _generateAndSaveResult(emit);
        return;
      }

      final question = turnResponse.question;
      if (question == null || question.trim().isEmpty) {
        emit(
          CameraInterviewLoadingErrorState(
            errorMessage: 'Unable to load next question.',
          ),
        );
        return;
      }

      emit(CameraInterviewLoadingSuccessState(question: question));
    }
  }

  Future<void> _generateAndSaveResult(
    Emitter<CameraInterviewState> emit,
  ) async {
    final result = await _geminiRepository.generateFinalEvaluation();

    if (!result.isSuccess) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: result.errorMessage ?? 'Unable to generate result.',
        ),
      );
      return;
    }

    final activeInterviewId = _activeInterviewId;
    if (activeInterviewId == null) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'Interview session was not saved. Please try again.',
        ),
      );
      return;
    }

    try {
      await _interviewPersistenceRepository.saveResultMarkdown(
        interviewId: activeInterviewId,
        resultMarkdown: result.data!,
      );
    } on InterviewPersistenceException catch (error) {
      emit(CameraInterviewLoadingErrorState(errorMessage: error.message));
      return;
    } catch (_) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'Could not save interview result. Please try again.',
        ),
      );
      return;
    }

    resultHistory.add(result.data!);
    emit(CameraInterviewResultState(result: result.data!));
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
