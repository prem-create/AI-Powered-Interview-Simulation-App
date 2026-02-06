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

        log("reply from gemini: $reply");
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
    // 1. Add candidate message to memory
    addCandidateAnswer(answer);
    log('candidate answer:$answer');

    // 2. Send full memory to Gemini
    final geminiReply = await sendToGemini();
    log('next question: $geminiReply');

    // 3. Return Gemini response (summary + next question)
    return geminiReply;
  }

  void startChat() {
    _contents.clear();

    _contents.add({
      "role": "user",
      "parts": [
        {
          "text": """
You are an AI chat companion for a user in a ai powered interview simulation app. Your role is to:

1. **Engage in natural, friendly conversation** with the user.
2. **Answer questions clearly and helpfully** based on general knowledge.
3. Keep responses **concise but informative**, around 2–5 sentences.
4. **Do not ask the user for sensitive information** like passwords, personal documents, or financial info.
5. **Distinguish between casual chat and guidance**: provide advice only when asked, otherwise respond conversationally.
6. **Keep context of the current chat**: remember previous messages during this session for continuity.
7. Format responses in plain text; do not add code unless explicitly requested.
8. Optionally, provide **fun, engaging remarks** to make the chat interactive.
9. this message is sent to you means the chat page is opened by the user so greet the user and offer help to start the chat.

Always be **polite, positive, and professional**, but casual enough to feel like a chat companion.
""",
        },
      ],
    });
  }
}
