import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/pages/camera_interview_page/logic/tts_logic.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_persistence_exception.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_scorecard_entry.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_session_details.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_turn_response.dart';
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

    on<CandidateAnswerTranscriptionStartedEvent>(
      candidateAnswerTranscriptionStartedEvent,
    );

    on<CandidateAnswerTranscriptionFailedEvent>(
      candidateAnswerTranscriptionFailedEvent,
    );

    on<RetryLastInterviewActionEvent>(retryLastInterviewActionEvent);

    on<SpeakTtsEvent>(speakTtsEvent);

    on<CameraInterviewLifecyclePausedEvent>(
      cameraInterviewLifecyclePausedEvent,
    );
  }

  final GeminiRepository _geminiRepository;
  final InterviewPersistenceRepository _interviewPersistenceRepository;
  final TtsLogic _ttsLogic = TtsLogic();
  String? _activeInterviewId;
  _CameraInterviewRetryAction? _lastRetryAction;

  // camera interview button tapped
  FutureOr<void> cameraInterviewInitialEvent(
    CameraInterviewInitialEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    _clearRetryAction();
    emit(CameraInterviewInitial());
  }

  // start interview button tapped
  FutureOr<void> askInterviewDetailsEvent(
    AskInterviewDetailsEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    _clearRetryAction();
    emit(AskInterviewDetailsState());
  }

  //proceed button tapped
  FutureOr<void> startCameraInterviewButtonTappedEvent(
    StartCameraInterviewButtonTappedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());
    _clearRetryAction();
    await _createSessionAndLoadFirstQuestion(event, emit);
  }

  // _createSessionAndLoadFirstQuestion() would create a interview in firestore but question pool is yet not generated
  Future<void> _createSessionAndLoadFirstQuestion(
    StartCameraInterviewButtonTappedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
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
      emit(
        _retryableErrorState(
          error.message,
          _CreateSessionAndLoadFirstQuestionRetryAction(event),
        ),
      );
      return;
    } catch (_) {
      emit(
        _retryableErrorState(
          'Could not save interview details. Please try again.',
          _CreateSessionAndLoadFirstQuestionRetryAction(event),
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

    await _loadFirstQuestion(emit);
  }

  //_loadFirstQuestion() will generate the pool and eventually launch first question from the pool
  Future<void> _loadFirstQuestion(Emitter<CameraInterviewState> emit) async {
    //sendToGemini will make a api call using the json body we created above
    final firstQuestion = await _geminiRepository.sendToGemini();

    //if question is empty launch error state
    if (!firstQuestion.isSuccess) {
      emit(
        _retryableErrorState(
          firstQuestion.errorMessage ?? 'Unable to load question.',
          _LoadFirstQuestionRetryAction(),
        ),
      );
      return;
    }

    _clearRetryAction();
    emit(CameraInterviewLoadingSuccessState(question: firstQuestion.data!));
  }

  // when user complete answering
  FutureOr<void> candidateAnswerTranscriptionStartedEvent(
    CandidateAnswerTranscriptionStartedEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(CameraInterviewLoadingState());
  }

  FutureOr<void> candidateAnswerTranscriptionFailedEvent(
    CandidateAnswerTranscriptionFailedEvent event,
    Emitter<CameraInterviewState> emit,
  ) {
    emit(
      CameraInterviewLoadingErrorState(
        errorMessage: event.errorMessage,
        canRetryAction: false,
      ),
    );
  }

  FutureOr<void> retryLastInterviewActionEvent(
    RetryLastInterviewActionEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    final retryAction = _lastRetryAction;
    if (retryAction == null) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'There is no retryable interview action available.',
          canRetryAction: false,
        ),
      );
      return;
    }

    emit(CameraInterviewLoadingState());
    _clearRetryAction();
    await retryAction.retry(this, emit);
  }

  FutureOr<void> candidateAnswerSubmittedEvent(
    CandidateAnswerSubmittedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    emit(CameraInterviewLoadingState());
    _clearRetryAction();

    if (event.isEndInterviewButtonTapped) {
      await _generateAndSaveResult(emit);
    } else {
      await _submitCandidateAnswer(event.answer, emit);
    }
  }

  Future<void> _submitCandidateAnswer(
    String answer,
    Emitter<CameraInterviewState> emit,
  ) async {
    final nextQuestion = await _geminiRepository.submitCandidateAnswer(answer);

    if (!nextQuestion.isSuccess) {
      emit(
        _retryableErrorState(
          nextQuestion.errorMessage ?? 'Unable to load next question.',
          _SubmitCandidateAnswerRetryAction(answer),
        ),
      );
      return;
    }

    final turnResponse = nextQuestion.data!;
    final activeInterviewId = _activeInterviewId;
    if (activeInterviewId == null) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'Interview session was not saved. Please try again.',
          canRetryAction: false,
        ),
      );
      return;
    }

    final scorecard = _geminiRepository.scorecard;
    if (scorecard.isEmpty) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'Interview answer was not captured. Please try again.',
          canRetryAction: false,
        ),
      );
      return;
    }

    await _saveAnswerTurnAndContinue(
      interviewId: activeInterviewId,
      turnNumber: scorecard.length,
      scorecardEntry: scorecard.last,
      turnResponse: turnResponse,
      emit: emit,
    );
  }

  Future<void> _saveAnswerTurnAndContinue({
    required String interviewId,
    required int turnNumber,
    required InterviewScorecardEntry scorecardEntry,
    required InterviewTurnResponse turnResponse,
    required Emitter<CameraInterviewState> emit,
  }) async {
    try {
      await _interviewPersistenceRepository.saveAnswerTurn(
        interviewId: interviewId,
        turnNumber: turnNumber,
        scorecardEntry: scorecardEntry,
      );
    } on InterviewPersistenceException catch (error) {
      emit(
        _retryableErrorState(
          error.message,
          _SaveAnswerTurnRetryAction(
            interviewId: interviewId,
            turnNumber: turnNumber,
            scorecardEntry: scorecardEntry,
            turnResponse: turnResponse,
          ),
        ),
      );
      return;
    } catch (_) {
      emit(
        _retryableErrorState(
          'Could not save interview answer. Please try again.',
          _SaveAnswerTurnRetryAction(
            interviewId: interviewId,
            turnNumber: turnNumber,
            scorecardEntry: scorecardEntry,
            turnResponse: turnResponse,
          ),
        ),
      );
      return;
    }

    await _continueAfterAnswerTurn(turnResponse, emit);
  }

  Future<void> _continueAfterAnswerTurn(
    InterviewTurnResponse turnResponse,
    Emitter<CameraInterviewState> emit,
  ) async {
    if (turnResponse.shouldGenerateResult) {
      await _generateAndSaveResult(emit);
      return;
    }

    final question = turnResponse.question;
    if (question == null || question.trim().isEmpty) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'Unable to load next question.',
          canRetryAction: false,
        ),
      );
      return;
    }

    _clearRetryAction();
    emit(CameraInterviewLoadingSuccessState(question: question));
  }

  Future<void> _generateAndSaveResult(
    Emitter<CameraInterviewState> emit,
  ) async {
    final result = await _geminiRepository.generateFinalEvaluation();

    if (!result.isSuccess) {
      emit(
        _retryableErrorState(
          result.errorMessage ?? 'Unable to generate result.',
          _GenerateAndSaveResultRetryAction(),
        ),
      );
      return;
    }

    final activeInterviewId = _activeInterviewId;
    if (activeInterviewId == null) {
      emit(
        CameraInterviewLoadingErrorState(
          errorMessage: 'Interview session was not saved. Please try again.',
          canRetryAction: false,
        ),
      );
      return;
    }

    await _saveResultAndEmit(
      interviewId: activeInterviewId,
      resultMarkdown: result.data!,
      emit: emit,
    );
  }

  Future<void> _saveResultAndEmit({
    required String interviewId,
    required String resultMarkdown,
    required Emitter<CameraInterviewState> emit,
  }) async {
    try {
      await _interviewPersistenceRepository.saveResultMarkdown(
        interviewId: interviewId,
        resultMarkdown: resultMarkdown,
      );
    } on InterviewPersistenceException catch (error) {
      emit(
        _retryableErrorState(
          error.message,
          _SaveResultRetryAction(
            interviewId: interviewId,
            resultMarkdown: resultMarkdown,
          ),
        ),
      );
      return;
    } catch (_) {
      emit(
        _retryableErrorState(
          'Could not save interview result. Please try again.',
          _SaveResultRetryAction(
            interviewId: interviewId,
            resultMarkdown: resultMarkdown,
          ),
        ),
      );
      return;
    }

    _clearRetryAction();
    resultHistory.add(resultMarkdown);
    emit(CameraInterviewResultState(result: resultMarkdown));
  }

  CameraInterviewLoadingErrorState _retryableErrorState(
    String message,
    _CameraInterviewRetryAction retryAction,
  ) {
    _lastRetryAction = retryAction;
    return CameraInterviewLoadingErrorState(errorMessage: message);
  }

  void _clearRetryAction() {
    _lastRetryAction = null;
  }

  FutureOr<void> speakTtsEvent(
    SpeakTtsEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    _ttsLogic.initializeTts();
    await _ttsLogic.speak(text: event.text);
  }

  FutureOr<void> cameraInterviewLifecyclePausedEvent(
    CameraInterviewLifecyclePausedEvent event,
    Emitter<CameraInterviewState> emit,
  ) async {
    await _ttsLogic.stopSpeaking();
  }

  @override
  Future<void> close() async {
    await _ttsLogic.stopSpeaking();
    return super.close();
  }
}

abstract class _CameraInterviewRetryAction {
  Future<void> retry(
    CameraInterviewBloc bloc,
    Emitter<CameraInterviewState> emit,
  );
}

class _CreateSessionAndLoadFirstQuestionRetryAction
    implements _CameraInterviewRetryAction {
  const _CreateSessionAndLoadFirstQuestionRetryAction(this.event);

  final StartCameraInterviewButtonTappedEvent event;

  @override
  Future<void> retry(
    CameraInterviewBloc bloc,
    Emitter<CameraInterviewState> emit,
  ) {
    return bloc._createSessionAndLoadFirstQuestion(event, emit);
  }
}

class _LoadFirstQuestionRetryAction implements _CameraInterviewRetryAction {
  @override
  Future<void> retry(
    CameraInterviewBloc bloc,
    Emitter<CameraInterviewState> emit,
  ) {
    return bloc._loadFirstQuestion(emit);
  }
}

class _SubmitCandidateAnswerRetryAction implements _CameraInterviewRetryAction {
  const _SubmitCandidateAnswerRetryAction(this.answer);

  final String answer;

  @override
  Future<void> retry(
    CameraInterviewBloc bloc,
    Emitter<CameraInterviewState> emit,
  ) {
    return bloc._submitCandidateAnswer(answer, emit);
  }
}

class _SaveAnswerTurnRetryAction implements _CameraInterviewRetryAction {
  const _SaveAnswerTurnRetryAction({
    required this.interviewId,
    required this.turnNumber,
    required this.scorecardEntry,
    required this.turnResponse,
  });

  final String interviewId;
  final int turnNumber;
  final InterviewScorecardEntry scorecardEntry;
  final InterviewTurnResponse turnResponse;

  @override
  Future<void> retry(
    CameraInterviewBloc bloc,
    Emitter<CameraInterviewState> emit,
  ) {
    return bloc._saveAnswerTurnAndContinue(
      interviewId: interviewId,
      turnNumber: turnNumber,
      scorecardEntry: scorecardEntry,
      turnResponse: turnResponse,
      emit: emit,
    );
  }
}

class _GenerateAndSaveResultRetryAction implements _CameraInterviewRetryAction {
  @override
  Future<void> retry(
    CameraInterviewBloc bloc,
    Emitter<CameraInterviewState> emit,
  ) {
    return bloc._generateAndSaveResult(emit);
  }
}

class _SaveResultRetryAction implements _CameraInterviewRetryAction {
  const _SaveResultRetryAction({
    required this.interviewId,
    required this.resultMarkdown,
  });

  final String interviewId;
  final String resultMarkdown;

  @override
  Future<void> retry(
    CameraInterviewBloc bloc,
    Emitter<CameraInterviewState> emit,
  ) {
    return bloc._saveResultAndEmit(
      interviewId: interviewId,
      resultMarkdown: resultMarkdown,
      emit: emit,
    );
  }
}
