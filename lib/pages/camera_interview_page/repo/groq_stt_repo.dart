import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/core/utils/errors_handler.dart';

class GroqSttRepo {
  static const Duration _requestTimeout = Duration(seconds: 30);
  static final Uri _url = Uri.parse(
    'https://api.groq.com/openai/v1/audio/transcriptions',
  );

  Future<ApiResult<String>> transcribe({required File file}) async {
    try {
      final request = http.MultipartRequest('POST', _url)
        ..headers['Authorization'] = 'Bearer $googleCloudSttApiKey'
        ..fields['model'] = 'whisper-large-v3-turbo'
        ..fields['language'] = 'en'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send().timeout(_requestTimeout);
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        log('Groq STT request failed: ${response.statusCode} ${response.body}');
        return ApiResult.failure(
          ErrorsHandler.groqSttStatusCodeMessage(response.statusCode),
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final transcript = data['text'] as String?;
      if (transcript == null || transcript.trim().isEmpty) {
        return ApiResult.failure(ErrorsHandler.groqSttEmptyResponseMessage());
      }

      return ApiResult.success(transcript);
    } on FormatException catch (error, stackTrace) {
      log(
        'Unable to parse Groq STT response',
        error: error,
        stackTrace: stackTrace,
      );
      return ApiResult.failure(ErrorsHandler.groqSttParsingMessage());
    } on http.ClientException catch (error, stackTrace) {
      log(
        'Groq STT network request failed',
        error: error,
        stackTrace: stackTrace,
      );
      return ApiResult.failure(ErrorsHandler.groqSttNetworkMessage());
    } on TimeoutException catch (error, stackTrace) {
      log('Groq STT request timed out', error: error, stackTrace: stackTrace);
      return ApiResult.failure(ErrorsHandler.groqSttTimeoutMessage());
    } catch (error, stackTrace) {
      log('Groq STT request failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(ErrorsHandler.groqSttNetworkMessage());
    }
  }
}
