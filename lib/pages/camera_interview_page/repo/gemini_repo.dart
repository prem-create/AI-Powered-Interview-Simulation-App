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

class GeminiRepository {
  final GeminiApiService _apiService;

  GeminiRepository(this._apiService);

  final List<Message> _messages = [];
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
    _messages.clear();
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

    _messages.add(
      Message(
        role: "user",
        text: _buildLegacyInterviewPrompt(
          candidateName: candidateName,
          interviewTopic: interviewTopic,
          difficultyLevel: difficultyLevel,
          interviewType: interviewType,
          yearsOfExperience: yearsOfExperience,
        ),
      ),
    );
  }

  String _buildLegacyInterviewPrompt({
    required String candidateName,
    required String interviewTopic,
    required String difficultyLevel,
    required String interviewType,
    required String yearsOfExperience,
  }) {
    return """
You are a professional technical interviewer.

Interview details:

* Candidate Name: $candidateName
* Interview Topic: $interviewTopic
* Difficulty Level: $difficultyLevel
* Interview Type: $interviewType
* Years of Experience: $yearsOfExperience

Instructions:

1. Ask one question at a time.
2. Keep questions short, clear, and highly TTS-friendly (avoid complex or long sentences).
3. Stay strictly within the given topic, difficulty level, interview type, and years of experience.
4. Use simple wording so speech-to-text systems can accurately capture responses.
5. Avoid special characters such as quotation marks, asterisks, or symbols that may interfere with TTS or STT.
6. Prefer commonly spoken forms of technical terms where possible.
7. Be adaptive and understanding that responses may come from speech-to-text and may contain minor errors.
8. If a response seems unclear, ask a short follow-up instead of assuming it is wrong.
9. Continue asking questions until the user says "End Interview".

When "End Interview" is received:
Generate a complete evaluation report.

Report Requirements (use proper Markdown formatting):

1. Use clear section headings with ## and ###.
2. Use bullet points and numbered lists wherever appropriate.
3. Highlight important terms using bold text.
4. Keep spacing clean and readable.
5. Use short paragraphs instead of long blocks of text.

Evaluation Sections:

## Candidate Summary

* Brief overview of performance
* Communication clarity (considering STT limitations)

## Strengths

* Technical understanding
* Clarity of explanation
* Problem-solving approach

## Weaknesses

* Conceptual gaps
* Incorrect or incomplete answers
* Communication issues (if any)

## Question-wise Feedback

* Each question with:

  * Expected concept
  * Candidate response summary
  * Evaluation (Correct / Partial / Incorrect)
  * Improvement tip

## Suggestions for Improvement

* Specific topics to revise
* Practical actions (projects, practice, etc.)

## Final Evaluation

* Overall rating (Beginner / Intermediate / Strong)
* Short justification

Additional Instructions:

* Be lenient with minor transcription errors due to speech-to-text.
* Focus more on intent and conceptual correctness than exact wording.
* Do not penalize small grammar or pronunciation-related mistakes.
* Keep feedback constructive and actionable.
  """;
  }

  // ================= SEND TO GEMINI =================
  Future<ApiResult<String>> sendToGemini() async {
    if (!_hasAskedInitialPoolQuestion) {
      return await _loadPoolAndSelectInitialQuestion();
    }

    return _sendToGemini(
      modelTier: GeminiModelTier.primary,
      fallbackToSecondary: true,
    );
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
          text: _buildQuestionPoolPrompt(interviewDetails),
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
    _messages.add(Message(role: 'model', text: question.question));
  }

  String _normalizeDifficulty(String? difficulty) {
    final value = difficulty?.trim().toLowerCase() ?? '';
    if (value.contains('hard')) return 'hard';
    if (value.contains('medium')) return 'medium';
    return 'easy';
  }

  String _buildQuestionPoolPrompt(InterviewSessionDetails details) {
    return """
You are a professional technical interviewer.

Generate a reusable interview question pool for this session.

Candidate Name: ${details.candidateName}
Interview Topic: ${details.interviewTopic}
Difficulty Level: ${details.difficultyLevel}
Interview Type: ${details.interviewType}
Years of Experience: ${details.yearsOfExperience}

Requirements:
1. Generate exactly 15 questions.
2. Include 5 easy, 5 medium, and 5 hard questions.
3. Questions must be short, clear, TTS-friendly, and suitable for speech answers.
4. Stay strictly within the interview topic, type, difficulty, and experience level.
5. Avoid quotation marks, markdown, bullets, symbols, and multi-part questions inside question text.
6. Each question must include 2 to 4 lowercase topic tags.
7. Return only valid JSON.

JSON shape:
{
  "questions": [
    {
      "id": "q1",
      "question": "Explain ...",
      "difficulty": "easy",
      "tags": ["tag_one", "tag_two"]
    }
  ]
}
""";
  }

  Future<ApiResult<String>> _sendToGemini({
    required GeminiModelTier modelTier,
    bool fallbackToSecondary = false,
  }) async {
    final response = await _apiService.send(
      _messages.map((e) => e.toJson()).toList(),
      modelTier: modelTier,
    );

    if (!response.isSuccess &&
        fallbackToSecondary &&
        modelTier != GeminiModelTier.secondary) {
      return _sendToGemini(modelTier: GeminiModelTier.secondary);
    }

    if (!response.isSuccess) {
      return ApiResult.failure(
        response.errorMessage ?? ErrorsHandler.geminiEmptyResponseMessage(),
        statusCode: response.statusCode,
      );
    }

    final post = response.data;
    if (post == null || post.candidates.isEmpty) {
      if (fallbackToSecondary && modelTier != GeminiModelTier.secondary) {
        return _sendToGemini(modelTier: GeminiModelTier.secondary);
      }

      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    final reply = _extractText(post);
    if (reply == null || reply.trim().isEmpty) {
      if (fallbackToSecondary && modelTier != GeminiModelTier.secondary) {
        return _sendToGemini(modelTier: GeminiModelTier.secondary);
      }

      return ApiResult.failure(ErrorsHandler.geminiEmptyResponseMessage());
    }

    // store AI reply
    _messages.add(Message(role: "model", text: reply));

    return ApiResult.success(reply);
  }

  // ================= ADD USER ANSWER =================
  void addCandidateAnswer(String answer) {
    _messages.add(Message(role: "user", text: answer));
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
    addCandidateAnswer(answer);
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
      _messages.add(Message(role: 'model', text: followUpQuestion));
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
    final response = await _apiService.send(
      [
        Message(
          role: 'user',
          text: _buildAdaptiveDecisionPrompt(answer),
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

  String _buildAdaptiveDecisionPrompt(String answer) {
    final activeQuestion = _activeQuestion!;
    final interviewDetails = _interviewDetails!;

    return """
You are an adaptive interview decision engine.

Return only valid JSON. Do not return markdown or prose.

Interview context:
Topic: ${interviewDetails.interviewTopic}
Interview Type: ${interviewDetails.interviewType}
Years of Experience: ${interviewDetails.yearsOfExperience}
Current Difficulty: ${activeQuestion.difficulty}
Current Question Tags: ${jsonEncode(activeQuestion.tags)}
Covered Tags: ${jsonEncode(_coveredTags())}
Unused Pool Preview: ${jsonEncode(_unusedPoolPreview())}
Consecutive Follow Ups For Current Question: $_consecutiveFollowUps

Current Question:
${activeQuestion.question}

Candidate Answer:
$answer

Decision rules:
1. Use follow_up only when the answer is unclear, incomplete, or worth probing deeper.
2. Use use_pool when the answer is good enough to move forward or the topic is already covered.
3. Never suggest follow_up when consecutive follow ups is 2 or more.
4. The follow_up_question must be short, clear, TTS-friendly, and one sentence.
5. Set difficulty_signal to up for strong answers, down for weak answers, same otherwise.

JSON shape:
{
  "action": "follow_up",
  "answer_quality": "partial",
  "difficulty_signal": "same",
  "follow_up_question": "Can you clarify ...",
  "suggest_wrap_up": false
}
""";
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
        text: _buildFinalEvaluationPrompt(interviewDetails),
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

  String _buildFinalEvaluationPrompt(InterviewSessionDetails details) {
    return """
You are a professional technical interviewer.

Generate a complete evaluation report from this compact interview scorecard.
Do not assume any extra answers beyond the scorecard.

Interview details:
Candidate Name: ${details.candidateName}
Interview Topic: ${details.interviewTopic}
Difficulty Level: ${details.difficultyLevel}
Interview Type: ${details.interviewType}
Years of Experience: ${details.yearsOfExperience}
Questions Answered: ${_scorecard.length}
Question Budget: ${_questionBudget.minQuestions}-${_questionBudget.maxQuestions}

Scorecard JSON:
${jsonEncode(_scorecard.map((entry) => entry.toJson()).toList(growable: false))}

Report Requirements:
1. Use proper Markdown formatting.
2. Use clear section headings with ## and ###.
3. Use bullet points and numbered lists wherever appropriate.
4. Highlight important terms using bold text.
5. Keep spacing clean and readable.
6. Be lenient with minor speech-to-text transcription errors.
7. Focus more on intent and conceptual correctness than exact wording.
8. Keep feedback constructive and actionable.

Evaluation Sections:

## Candidate Summary

## Strengths

## Weaknesses

## Question-wise Feedback

For each question include:
- Expected concept
- Candidate response summary
- Evaluation as Correct, Partial, or Incorrect
- Improvement tip

## Suggestions for Improvement

## Final Evaluation

Include overall rating as Beginner, Intermediate, or Strong with a short justification and interview readiness status.
""";
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
