import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/core/utils/errors_handler.dart';

class GoogleSttRepo {
  static const Duration _requestTimeout = Duration(seconds: 30);
  final url = Uri.parse(
    'https://speech.googleapis.com/v1/speech:recognize?key=$googleCloudSttApiKey',
  );
  final Map<String, dynamic> config = {
    "encoding": "FLAC",
    "languageCode": "en-IN",
    "model": "latest_long",
  };

  Future<ApiResult<String>> sendToGoogleStt({
    required final String base64,
  }) async {
    try {
      log('post sent intialized');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "config": config,
              "audio": {"content": base64},
            }),
          )
          .timeout(_requestTimeout);
      log(response.statusCode.toString());
      if (response.statusCode != 200) {
        log(response.body);
        return ApiResult.failure(
          ErrorsHandler.googleSttStatusCodeMessage(response.statusCode),
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      log(response.body);

      final transcript =
          data['results']?[0]?['alternatives']?[0]?['transcript'] as String?;

      if (transcript != null) log('got transcription');
      log(transcript.toString());

      if (transcript == null || transcript.trim().isEmpty) {
        return ApiResult.failure(ErrorsHandler.googleSttEmptyResponseMessage());
      }

      return ApiResult.success(transcript);
    } on FormatException catch (error, stackTrace) {
      log(
        'Unable to parse Google STT response',
        error: error,
        stackTrace: stackTrace,
      );
      return ApiResult.failure(ErrorsHandler.googleSttParsingMessage());
    } on http.ClientException catch (error, stackTrace) {
      log(
        'Google STT network request failed',
        error: error,
        stackTrace: stackTrace,
      );
      return ApiResult.failure(ErrorsHandler.googleSttNetworkMessage());
    } on TimeoutException catch (error, stackTrace) {
      log('Google STT request timed out', error: error, stackTrace: stackTrace);
      return ApiResult.failure(ErrorsHandler.googleSttTimeoutMessage());
    } catch (error, stackTrace) {
      log('Google STT request failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(ErrorsHandler.googleSttNetworkMessage());
    }
  }
}
