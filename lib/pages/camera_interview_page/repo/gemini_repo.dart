import 'package:interview_app/core/utils/errors_handler.dart';

import '../models/message_model.dart';
import '../models/gemini_response_model.dart';
import '../services/gemini_api_service.dart';

class GeminiRepository {
  final GeminiApiService _apiService;

  GeminiRepository(this._apiService);

  final List<Message> _messages = [];

  // ================= START INTERVIEW =================
  void startInterview({
    required String candidateName,
    required String interviewTopic,
    required String difficultyLevel,
    required String interviewType,
    required String yearsOfExperience,
  }) {
    _messages.clear();

    _messages.add(
      Message(
        role: "user",
        text:
            """
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
  """,
      ),
    );
  }

  // ================= SEND TO GEMINI =================
  Future<ApiResult<String>> sendToGemini() async {
    return _sendToGemini(
      modelTier: GeminiModelTier.primary,
      fallbackToSecondary: true,
    );
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
