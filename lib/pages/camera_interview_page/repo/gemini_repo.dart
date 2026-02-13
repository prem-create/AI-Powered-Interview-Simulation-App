// ============================================================================
// GEMINI REPOSITORY - AI Communication Layer for Camera Interview
// ============================================================================
// Handles all communication with Google's Gemini AI API
// 
// RESPONSIBILITIES:
// 1. Maintain conversation context (memory of all questions and answers)
// 2. Send requests to Gemini API with proper formatting
// 3. Parse AI responses and extract questions/feedback
// 4. Initialize interview with prompt engineering for professional behavior
// 
// CONVERSATION FLOW:
// 1. startInterview() → Sets up AI as professional interviewer with instructions
// 2. sendToGemini() → Sends conversation history, receives AI response
// 3. addCandidateAnswer() → Adds user answer to conversation memory
// 4. sendCandidateAnswer() → Combines steps 3 & 2 for convenience
// 
// PROMPT ENGINEERING:
// - AI acts strictly as interviewer (not helper/explainer)
// - Questions are TTS-friendly (clear, concise, spoken-language)
// - Adjusts difficulty based on user selection
// - Generates comprehensive report when interview ends
// 
// TODO: Add retry logic for failed API calls
// TODO: Implement rate limiting to avoid API quota issues
// TODO: Add caching for common questions to reduce API costs
// ============================================================================

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:interview_app/core/constants/constants.dart';

/// Repository for managing Gemini AI communication during camera interview
class GeminiRepository {
  // Conversation memory - stores all messages between user and AI
  // Format: [{"role": "user/model", "parts": [{"text": "message"}]}]
  final List<Map<String, dynamic>> _contents = [];

  // Gemini API endpoint for content generation
  Uri url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent',
  );

  /// Sends current conversation to Gemini and receives AI response
  /// Returns: AI's next question or null if error occurs
  Future<String?> sendToGemini() async {
    final body = jsonEncode({"contents": _contents});

    try {
      log('body: contents:{${_contents}}');
      
      // Make POST request to Gemini API
      final response = await http.post(
        url,
        headers: {
          //it won't work untill we enter valid api here. i removed the api on purpose
          'x-goog-api-key': apiKey, // API key from constants
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic>> result = jsonDecode(response.body);
        log(response.body);

        // Extract AI response from nested JSON structure
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

        // Store Gemini reply in conversation memory for context
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

  /// Adds candidate's answer to conversation memory
  /// This maintains context for AI to ask relevant follow-up questions
  void addCandidateAnswer(String answer) {
    _contents.add({
      "role": "user",
      "parts": [
        {"text": answer},
      ],
    });
  }

  /// Convenience method: Add answer to memory and get next question
  /// Returns: AI's next question or final report if interview ended
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

  /// Initializes interview session with prompt engineering
  /// Sets up AI behavior, interview parameters, and ending instructions
  /// 
  /// PROMPT DESIGN:
  /// - Professional interviewer persona
  /// - TTS-friendly questions (clear, concise)
  /// - One question at a time
  /// - Contextual follow-ups based on answers
  /// - Comprehensive report generation on "End Interview" signal
  void startInterview({
    required final String candidateName,
    required final String InterviewTopic,
    required final String difficultyLevel,
  }) {
    // Clear previous conversation
    _contents.clear();

    // Add system prompt with interview instructions
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
2. Ask one question at a time and wait for the candidate's response before continuing.
3. Adjust follow-up questions based on the candidate's answers while staying within the given topic and difficulty level.
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
