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
  }) {
    _messages.clear();

    _messages.add(
      Message(
        role: "user",
text: """
You are a professional technical interviewer.

Interview details:

* Candidate Name: $candidateName
* Interview Topic: $interviewTopic
* Difficulty Level: $difficultyLevel

Instructions:

1. Ask one question at a time.
2. Keep questions short, clear, and highly TTS-friendly (avoid complex or long sentences).
3. Stay strictly within the given topic and difficulty level.
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
  """

      ),
    );
  }

  // ================= SEND TO GEMINI =================
  Future<String?> sendToGemini() async {
    final response = await _apiService.send(
      _messages.map((e) => e.toJson()).toList(),
    );

    if (response == null || response.candidates.isEmpty) return null;

    final reply = _extractText(response);

    // store AI reply
    _messages.add(
      Message(role: "model", text: reply),
    );

    return reply;
  }

  // ================= ADD USER ANSWER =================
  void addCandidateAnswer(String answer) {
    _messages.add(
      Message(role: "user", text: answer),
    );
  }

  // ================= MAIN METHOD =================
  Future<String?> sendCandidateAnswer(String answer) async {
    addCandidateAnswer(answer);
    return await sendToGemini();
  }

  // ================= HELPER =================
  String _extractText(Post response) {
    return response
        .candidates
        .first
        .content
        .parts
        .first
        .text;
  }
}