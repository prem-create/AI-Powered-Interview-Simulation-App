import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:interview_app/core/constants/constants.dart';

class GeminiRepository {
  final List<Map<String, dynamic>> _contents = [];

  Uri url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent',
  );

  Future<String?> sendToGemini() async {
    final body = jsonEncode({"contents": _contents});

    try {
      log('body: contents:{${_contents}}');
      final response = await http.post(
        url,
        headers: {
          //it won't work untill we enter valid api here. i removed the api on purpose
          'x-goog-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        log(response.body);

        final candidates = result["candidates"];
        if (candidates == null || candidates.isEmpty) {
          log("No candidates in response: $result");
          return null;
        }

        final content = candidates.first["content"];
        final parts = content?["parts"];
        if (parts == null || parts.isEmpty) {
          log("No parts in candidate content: $content");
          return null;
        }

        final reply = parts.first["text"];
        if (reply == null || reply.isEmpty) {
          log("Reply is empty: $parts");
          return null;
        }

        // Store Gemini reply in memory
        _contents.add({
          "role": "model",
          "parts": [
            {"text": reply},
          ],
        });

        log("Next question from Gemini: $reply");
        return reply;
      } else {
        log('Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  void addCandidateAnswer(String answer) {
    _contents.add({
      "role": "user",
      "parts": [
        {"text": answer},
      ],
    });
  }

  Future<String?> sendCandidateAnswer(String answer) async {
    // 1. Add candidate answer to memory
    addCandidateAnswer(answer);
    log('candidate answer:$answer');

    // 2. Send full memory to Gemini
    final nextQuestion = await sendToGemini();
    log('next question: $nextQuestion');

    // 3. Return Gemini response (summary + next question)
    return nextQuestion;
  }

  void startInterview({
    required final String candidateName,
    required final String InterviewTopic,
    required final String difficultyLevel,
  }) {
    _contents.clear();

    _contents.add({
      "role": "user",
      "parts": [
        {
          "text": """
You are a professional technical interviewer.

Interview details:
- Candidate Name: $candidateName
- Interview Topic: $InterviewTopic
- Difficulty Level: $difficultyLevel

Instructions:
1. Act strictly as an interviewer. This interview will be conducted using text-to-speech and speech-to-text, so keep questions clear, concise, and spoken-language friendly.
2. Ask one question at a time and wait for the candidate’s response before continuing.
3. Adjust follow-up questions based on the candidate’s answers while staying within the given topic and difficulty level.
4. If the candidate goes off-topic, politely redirect them back to the interview topic.
5. Do NOT switch roles, do NOT explain answers unless explicitly required for evaluation.
6. Continue the interview until the candidate sends the exact message: "End Interview".

Ending Instructions:
- When the message "End Interview" is received, stop asking questions immediately.
- Generate a **professional interview report** that includes:
   - Overall performance summary
   - Strengths
   - Weak areas
   - Conceptual gaps
   - Practical improvement suggestions
   - Topics the candidate should revise
   - Mock questions for further practice
   - Final readiness assessment based on the selected difficulty level

Maintain a formal, professional interviewer tone throughout the session.

""",
        },
      ],
    });
  }
}
