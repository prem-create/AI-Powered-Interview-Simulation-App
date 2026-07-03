import 'dart:convert';

import 'package:interview_app/core/utils/errors_handler.dart';

import '../models/gemini_response_model.dart';
import '../models/interview_question_pool.dart';
import '../models/interview_session_details.dart';
import '../models/message_model.dart';
import '../services/gemini_api_service.dart';

class GeminiRepository {
  final GeminiApiService _apiService;

  GeminiRepository(this._apiService);

  final List<Message> _messages = [];
  InterviewSessionDetails? _interviewDetails;
  InterviewQuestionPool? _questionPool;
  final Set<String> _askedPoolQuestionIds = {};
  bool _hasAskedInitialPoolQuestion = false;

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
    _hasAskedInitialPoolQuestion = false;
    _interviewDetails = InterviewSessionDetails(
      candidateName: candidateName,
      interviewTopic: interviewTopic,
      difficultyLevel: difficultyLevel,
      interviewType: interviewType,
      yearsOfExperience: yearsOfExperience,
    );

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
    _markPoolQuestionAsked(selectedQuestion);
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
    final preferredDifficulty = _normalizeDifficulty(
      _interviewDetails?.difficultyLevel,
    );

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

  void _markPoolQuestionAsked(InterviewPoolQuestion question) {
    _askedPoolQuestionIds.add(question.id);
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
    addCandidateAnswer(answer);
    if (isResultRequest) {
      return await _sendToGemini(modelTier: GeminiModelTier.secondary);
    }

    return await sendToGemini();
  }

  // ================= HELPER =================
  String? _extractText(Post response) {
    final parts = response.candidates.first.content.parts;
    if (parts.isEmpty) return null;
    return parts.first.text;
  }
}
