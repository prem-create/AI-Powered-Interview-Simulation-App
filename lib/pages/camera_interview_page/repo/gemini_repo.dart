import 'dart:convert';

import 'package:interview_app/core/utils/errors_handler.dart';

import '../models/gemini_response_model.dart';
import '../models/interview_adaptive_decision.dart';
import '../models/interview_question_budget.dart';
import '../models/interview_question_pool.dart';
import '../models/interview_scorecard_entry.dart';
import '../models/interview_session_details.dart';
import '../models/interview_turn_response.dart';
import '../models/message_model.dart';
import '../services/gemini_api_service.dart';
import 'interview_prompts.dart';

class GeminiRepository {
  final GeminiApiService _apiService;

  GeminiRepository(this._apiService);

  InterviewSessionDetails? _interviewDetails;
  InterviewQuestionPool? _questionPool;
  final Set<String> _askedPoolQuestionIds = {};
  final List<InterviewScorecardEntry> _scorecard = [];
  bool _hasAskedInitialPoolQuestion = false;
  _ActiveQuestion? _activeQuestion;
  String _currentDifficulty = 'easy';
  int _consecutiveFollowUps = 0;
  InterviewQuestionBudget _questionBudget = const InterviewQuestionBudget(
    minQuestions: 6,
    maxQuestions: 8,
  );

  List<InterviewScorecardEntry> get scorecard => List.unmodifiable(_scorecard);

  // ================= START INTERVIEW =================
  void startInterview({
    required String candidateName,
    required String interviewTopic,
    required String difficultyLevel,
    required String interviewType,
    required String yearsOfExperience,
  }) {
    _questionPool = null;
    _askedPoolQuestionIds.clear();
    _scorecard.clear();
    _hasAskedInitialPoolQuestion = false;
    _activeQuestion = null;
    _currentDifficulty = _normalizeDifficulty(difficultyLevel);
    _consecutiveFollowUps = 0;
    final interviewDetails = InterviewSessionDetails(
      candidateName: candidateName,
      interviewTopic: interviewTopic,
      difficultyLevel: difficultyLevel,
      interviewType: interviewType,
      yearsOfExperience: yearsOfExperience,
    );
    _interviewDetails = interviewDetails;
    _questionBudget = InterviewQuestionBudget.fromDetails(interviewDetails);
  }

  // ================= SEND TO GEMINI =================
  Future<ApiResult<String>> sendToGemini() async {
    if (!_hasAskedInitialPoolQuestion) {
      return await _loadPoolAndSelectInitialQuestion();
    }

    return ApiResult.failure('Interview already has an active question.');
  }

  Future<ApiResult<String>> _loadPoolAndSelectInitialQuestion() async {
    final poolResult = await _loadQuestionPool();
    if (!poolResult.isSuccess) {
      return ApiResult.failure(
        poolResult.errorMessage ?? ErrorsHandler.geminiEmptyResponseMessage(),
        statusCode: poolResult.statusCode,
      );
    }

    final selectedQuestion = _selectInitialQuestion(poolResult.data!);
    _markPoolQuestionAsked(selectedQuestion, resetFollowUps: true);
    _hasAskedInitialPoolQuestion = true;

    return ApiResult.success(selectedQuestion.question);
  }

  Future<ApiResult<InterviewQuestionPool>> _loadQuestionPool() async {
    if (_questionPool != null) {
      return ApiResult.success(_questionPool!);
    }

    final primaryResult = await _requestQuestionPool(GeminiModelTier.primary);
    if (primaryResult.isSuccess) {
      _questionPool = primaryResult.data;
      return primaryResult;
    }

    final secondaryResult = await _requestQuestionPool(
      GeminiModelTier.secondary,
    );
    if (secondaryResult.isSuccess) {
      _questionPool = secondaryResult.data;
      return secondaryResult;
    }

    return secondaryResult.errorMessage == null
        ? primaryResult
        : secondaryResult;
  }

  Future<ApiResult<InterviewQuestionPool>> _requestQuestionPool(
    GeminiModelTier modelTier,
  ) async {
    final interviewDetails = _interviewDetails;
    if (interviewDetails == null) {
      return ApiResult.failure('Interview details are missing.');
    }

    final response = await _apiService.send(
      [
        Message(
          role: 'user',
          text: buildQuestionPoolPrompt(interviewDetails),
        ).toJson(),
      ],
      modelTier: modelTier,
      generationConfig: const {'responseMimeType': 'application/json'},
    );

    if (!response.isSuccess) {
      return ApiResult.failure(
        response.errorMessage ?? ErrorsHandler.geminiEmptyResponseMessage(),
        statusCode: response.statusCode,
      );
    }

    final post = response.data;
    if (post == null || post.candidates.isEmpty) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    final reply = _extractText(post);
    if (reply == null || reply.trim().isEmpty) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    try {
      return ApiResult.success(_parseQuestionPool(reply));
    } on FormatException {
      return ApiResult.failure(ErrorsHandler.geminiParsingMessage());
    }
  }

  InterviewQuestionPool _parseQuestionPool(String responseText) {
    final decoded = jsonDecode(_stripJsonCodeFence(responseText));
    if (decoded is Map<String, dynamic>) {
      return InterviewQuestionPool.fromJson(decoded);
    }

    if (decoded is List) {
      return InterviewQuestionPool.fromJson({'questions': decoded});
    }

    throw const FormatException('Question pool response must be JSON.');
  }

  String _stripJsonCodeFence(String value) {
    final trimmed = value.trim();
    if (!trimmed.startsWith('```')) return trimmed;

    return trimmed
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();
  }

  InterviewPoolQuestion _selectInitialQuestion(InterviewQuestionPool pool) {
    return _selectPoolQuestion(pool, preferredDifficulty: _currentDifficulty);
  }

  InterviewPoolQuestion _selectPoolQuestion(
    InterviewQuestionPool pool, {
    required String preferredDifficulty,
  }) {
    final matchingQuestions = pool.questions.where((question) {
      return question.difficulty == preferredDifficulty &&
          !_askedPoolQuestionIds.contains(question.id);
    });

    if (matchingQuestions.isNotEmpty) {
      return matchingQuestions.first;
    }

    return pool.questions.firstWhere(
      (question) => !_askedPoolQuestionIds.contains(question.id),
      orElse: () => pool.questions.first,
    );
  }

  void _markPoolQuestionAsked(
    InterviewPoolQuestion question, {
    required bool resetFollowUps,
  }) {
    _askedPoolQuestionIds.add(question.id);
    _activeQuestion = _ActiveQuestion.fromPoolQuestion(question);
    _currentDifficulty = question.difficulty;
    if (resetFollowUps) {
      _consecutiveFollowUps = 0;
    }
  }

  String _normalizeDifficulty(String? difficulty) {
    final value = difficulty?.trim().toLowerCase() ?? '';
    if (value.contains('hard')) return 'hard';
    if (value.contains('medium')) return 'medium';
    return 'easy';
  }

  // ================= MAIN METHOD =================
  Future<ApiResult<String>> sendCandidateAnswer(
    String answer, {
    bool isResultRequest = false,
  }) async {
    if (isResultRequest) {
      return await generateFinalEvaluation();
    }

    final turnResponse = await submitCandidateAnswer(answer);
    if (!turnResponse.isSuccess) {
      return ApiResult.failure(
        turnResponse.errorMessage ?? ErrorsHandler.geminiEmptyResponseMessage(),
        statusCode: turnResponse.statusCode,
      );
    }

    final response = turnResponse.data!;
    if (response.shouldGenerateResult) {
      return ApiResult.failure('Interview question limit reached.');
    }

    final question = response.question;
    if (question == null || question.trim().isEmpty) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    return ApiResult.success(question);
  }

  Future<ApiResult<InterviewTurnResponse>> submitCandidateAnswer(
    String answer,
  ) async {
    return await _selectNextQuestion(answer);
  }

  Future<ApiResult<InterviewTurnResponse>> _selectNextQuestion(
    String answer,
  ) async {
    final activeQuestion = _activeQuestion;
    final pool = _questionPool;
    if (activeQuestion == null || pool == null) {
      final question = await sendToGemini();
      if (!question.isSuccess) {
        return ApiResult.failure(
          question.errorMessage ?? ErrorsHandler.geminiEmptyResponseMessage(),
          statusCode: question.statusCode,
        );
      }

      return ApiResult.success(InterviewTurnResponse.question(question.data!));
    }

    final decisionResult = await _requestAdaptiveDecision(answer);
    final decision =
        decisionResult.data ??
        const InterviewAdaptiveDecision(
          action: AdaptiveAction.usePool,
          answerQuality: AnswerQuality.partial,
          difficultySignal: DifficultySignal.same,
          suggestWrapUp: false,
        );

    _scorecard.add(
      InterviewScorecardEntry(
        question: activeQuestion.question,
        answer: answer,
        answerQuality: decision.answerQuality.value,
        difficulty: activeQuestion.difficulty,
        tags: activeQuestion.tags,
        source: activeQuestion.source,
      ),
    );

    if (_scorecard.length >= _questionBudget.maxQuestions) {
      return const ApiResult.success(InterviewTurnResponse.generateResult());
    }

    final canSuggestWrapUp =
        _scorecard.length >= _questionBudget.minQuestions &&
        decision.suggestWrapUp;

    final shouldAskFollowUp =
        decision.action == AdaptiveAction.followUp &&
        decision.followUpQuestion != null &&
        _consecutiveFollowUps < 2;

    if (shouldAskFollowUp) {
      final followUpQuestion = decision.followUpQuestion!;
      _consecutiveFollowUps++;
      _activeQuestion = activeQuestion.toFollowUp(followUpQuestion);
      _currentDifficulty = _difficultyFromSignal(decision.difficultySignal);
      return ApiResult.success(
        InterviewTurnResponse.question(
          followUpQuestion,
          canSuggestWrapUp: canSuggestWrapUp,
        ),
      );
    }

    final nextQuestion = _selectPoolQuestion(
      pool,
      preferredDifficulty: _difficultyFromSignal(decision.difficultySignal),
    );
    _markPoolQuestionAsked(nextQuestion, resetFollowUps: true);
    return ApiResult.success(
      InterviewTurnResponse.question(
        nextQuestion.question,
        canSuggestWrapUp: canSuggestWrapUp,
      ),
    );
  }

  Future<ApiResult<InterviewAdaptiveDecision>> _requestAdaptiveDecision(
    String answer,
  ) async {
    final activeQuestion = _activeQuestion;
    final interviewDetails = _interviewDetails;
    final pool = _questionPool;
    if (activeQuestion == null || interviewDetails == null || pool == null) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    final primaryResult = await _sendAdaptiveDecisionRequest(
      answer: answer,
      modelTier: GeminiModelTier.primary,
    );
    if (primaryResult.isSuccess) return primaryResult;

    final secondaryResult = await _sendAdaptiveDecisionRequest(
      answer: answer,
      modelTier: GeminiModelTier.secondary,
    );
    if (secondaryResult.isSuccess) return secondaryResult;

    return secondaryResult.errorMessage == null
        ? primaryResult
        : secondaryResult;
  }

  Future<ApiResult<InterviewAdaptiveDecision>> _sendAdaptiveDecisionRequest({
    required String answer,
    required GeminiModelTier modelTier,
  }) async {
    final activeQuestion = _activeQuestion!;
    final interviewDetails = _interviewDetails!;

    final response = await _apiService.send(
      [
        Message(
          role: 'user',
          text: buildAdaptiveDecisionPrompt(
            answer: answer,
            interviewTopic: interviewDetails.interviewTopic,
            interviewType: interviewDetails.interviewType,
            yearsOfExperience: interviewDetails.yearsOfExperience,
            currentDifficulty: activeQuestion.difficulty,
            currentQuestionTags: activeQuestion.tags,
            coveredTags: _coveredTags(),
            unusedPoolPreview: _unusedPoolPreview(),
            consecutiveFollowUps: _consecutiveFollowUps,
            currentQuestion: activeQuestion.question,
          ),
        ).toJson(),
      ],
      modelTier: modelTier,
      generationConfig: const {'responseMimeType': 'application/json'},
    );

    if (!response.isSuccess) {
      return ApiResult.failure(
        response.errorMessage ?? ErrorsHandler.geminiEmptyResponseMessage(),
        statusCode: response.statusCode,
      );
    }

    final post = response.data;
    if (post == null || post.candidates.isEmpty) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    final reply = _extractText(post);
    if (reply == null || reply.trim().isEmpty) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    try {
      return ApiResult.success(_parseAdaptiveDecision(reply));
    } on FormatException {
      return ApiResult.failure(ErrorsHandler.geminiParsingMessage());
    }
  }

  InterviewAdaptiveDecision _parseAdaptiveDecision(String responseText) {
    final decoded = jsonDecode(_stripJsonCodeFence(responseText));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Adaptive decision response must be JSON.');
    }

    return InterviewAdaptiveDecision.fromJson(decoded);
  }

  String _difficultyFromSignal(DifficultySignal signal) {
    const difficultyOrder = ['easy', 'medium', 'hard'];
    final currentIndex = difficultyOrder.indexOf(_currentDifficulty);
    final safeCurrentIndex = currentIndex == -1 ? 0 : currentIndex;

    switch (signal) {
      case DifficultySignal.up:
        final nextIndex = safeCurrentIndex + 1;
        return difficultyOrder[nextIndex.clamp(0, difficultyOrder.length - 1)];
      case DifficultySignal.down:
        final nextIndex = safeCurrentIndex - 1;
        return difficultyOrder[nextIndex.clamp(0, difficultyOrder.length - 1)];
      case DifficultySignal.same:
        return difficultyOrder[safeCurrentIndex];
    }
  }

  List<String> _coveredTags() {
    return _scorecard
        .expand((entry) => entry.tags)
        .toSet()
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _unusedPoolPreview() {
    final pool = _questionPool;
    if (pool == null) return const [];

    return pool.questions
        .where((question) => !_askedPoolQuestionIds.contains(question.id))
        .map(
          (question) => {
            'difficulty': question.difficulty,
            'tags': question.tags,
          },
        )
        .toList(growable: false);
  }

  Future<ApiResult<String>> generateFinalEvaluation() async {
    if (_scorecard.isEmpty) {
      return ApiResult.failure('No interview answers were captured.');
    }

    final primaryResult = await _requestFinalEvaluation(
      GeminiModelTier.secondary,
    );
    if (primaryResult.isSuccess) return primaryResult;

    final fallbackResult = await _requestFinalEvaluation(
      GeminiModelTier.primary,
    );
    if (fallbackResult.isSuccess) return fallbackResult;

    return fallbackResult.errorMessage == null ? primaryResult : fallbackResult;
  }

  Future<ApiResult<String>> _requestFinalEvaluation(
    GeminiModelTier modelTier,
  ) async {
    final interviewDetails = _interviewDetails;
    if (interviewDetails == null) {
      return ApiResult.failure('Interview details are missing.');
    }

    final response = await _apiService.send([
      Message(
        role: 'user',
        text: buildFinalEvaluationPrompt(
          details: interviewDetails,
          scorecard: _scorecard,
          questionBudget: _questionBudget,
        ),
      ).toJson(),
    ], modelTier: modelTier);

    if (!response.isSuccess) {
      return ApiResult.failure(
        response.errorMessage ?? ErrorsHandler.geminiEmptyResponseMessage(),
        statusCode: response.statusCode,
      );
    }

    final post = response.data;
    if (post == null || post.candidates.isEmpty) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    final reply = _extractText(post);
    if (reply == null || reply.trim().isEmpty) {
      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    return ApiResult.success(reply);
  }

  // ================= HELPER =================
  String? _extractText(Post response) {
    final parts = response.candidates.first.content.parts;
    if (parts.isEmpty) return null;
    return parts.first.text;
  }
}

class _ActiveQuestion {
  const _ActiveQuestion({
    required this.question,
    required this.difficulty,
    required this.tags,
    required this.source,
  });

  final String question;
  final String difficulty;
  final List<String> tags;
  final String source;

  factory _ActiveQuestion.fromPoolQuestion(InterviewPoolQuestion question) {
    return _ActiveQuestion(
      question: question.question,
      difficulty: question.difficulty,
      tags: question.tags,
      source: 'pool',
    );
  }

  _ActiveQuestion toFollowUp(String followUpQuestion) {
    return _ActiveQuestion(
      question: followUpQuestion,
      difficulty: difficulty,
      tags: tags,
      source: 'follow_up',
    );
  }
}
