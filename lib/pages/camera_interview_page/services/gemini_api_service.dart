import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/pages/camera_interview_page/models/gemini_response_model.dart';

class GeminiApiService {
  final Uri url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent',
  );

  Future<Post?> send(List<Map<String, dynamic>> contents) async {
    try {
      final response = await http.post(
        url,
        headers: {
          'x-goog-api-key': geminiApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"contents": contents}),
      );
      log(response.body);

      if (response.statusCode == 200) {
        return postFromJson(response.body); // ✅ USING MODEL
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}