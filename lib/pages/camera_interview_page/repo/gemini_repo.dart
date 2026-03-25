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
- Candidate Name: $candidateName
- Interview Topic: $interviewTopic
- Difficulty Level: $difficultyLevel

Instructions:
1. Ask one question at a time.
2. Keep questions short and TTS-friendly.
3. Stay in topic.
4. Continue until user says "End Interview".

When "End Interview" is received:
Generate full report with:
- Strengths
- Weaknesses
- Suggestions
- Final evaluation
""",
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