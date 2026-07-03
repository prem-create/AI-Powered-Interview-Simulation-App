import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/core/utils/errors_handler.dart';
import 'package:interview_app/pages/camera_interview_page/models/gemini_response_model.dart';

enum GeminiModelTier { primary, secondary }

class GeminiApiService {
  static const String _primaryModel = 'gemini-3.1-flash-lite';
  static const String _secondaryModel = 'gemini-3.5-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<ApiResult<Post>> send(
    List<Map<String, dynamic>> contents, {
    GeminiModelTier modelTier = GeminiModelTier.primary,
  }) async {
    try {
      if (geminiApiKey.trim().isEmpty) {
        return ApiResult.failure(ErrorsHandler.geminiApiKeyMessage());
      }

      final response = await http
          .post(
            _urlFor(modelTier),
            headers: {
              'x-goog-api-key': geminiApiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"contents": contents}),
          )
          .timeout(const Duration(seconds: 45));
      log(response.body);

      if (response.statusCode == 200) {
        try {
          return ApiResult.success(postFromJson(response.body));
        } on FormatException catch (e) {
          log('Gemini response parsing failed: $e');
          return ApiResult.failure(ErrorsHandler.geminiParsingMessage());
        } on TypeError catch (e) {
          log('Gemini response structure is invalid: $e');
          return ApiResult.failure(ErrorsHandler.geminiParsingMessage());
        } catch (e) {
          log('Gemini response structure is invalid: $e');
          return ApiResult.failure(ErrorsHandler.geminiParsingMessage());
        }
      }

      return ApiResult.failure(
        ErrorsHandler.geminiStatusCodeMessage(
          response.statusCode,
          backendStatus: _backendErrorStatus(response.body),
        ),
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (e) {
      log('Gemini request timed out: $e');
      return ApiResult.failure(ErrorsHandler.geminiTimeoutMessage());
    } on http.ClientException catch (e) {
      log('Gemini network error: $e');
      return ApiResult.failure(ErrorsHandler.geminiNetworkMessage());
    } catch (e) {
      if (e.toString().contains('geminiApiKey')) {
        log('Gemini API key is not initialized: $e');
        return ApiResult.failure(ErrorsHandler.geminiApiKeyMessage());
      }

      log('Gemini request failed: $e');
      return ApiResult.failure(ErrorsHandler.geminiNetworkMessage());
    }
  }

  String? _backendErrorStatus(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final error = decoded['error'];
      if (error is! Map<String, dynamic>) return null;

      final status = error['status'];
      if (status is String) return status;
      return null;
    } catch (_) {
      return null;
    }
  }

  Uri _urlFor(GeminiModelTier modelTier) {
    return Uri.parse('$_baseUrl/${_modelFor(modelTier)}:generateContent');
  }

  String _modelFor(GeminiModelTier modelTier) {
    switch (modelTier) {
      case GeminiModelTier.primary:
        return _primaryModel;
      case GeminiModelTier.secondary:
        return _secondaryModel;
    }
  }
}
