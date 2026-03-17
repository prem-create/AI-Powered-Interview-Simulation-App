import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class GoogleSttRepo {

  final url = Uri.parse(
    'https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyD9iEWqLk1bz5xgW5xAXwFRwn8G-TNrhUI',
  );


  Future<String?> sendToGoogleStt({required final String base64}) async {
    log('post sent intialized');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "config": {
          "encoding": "FLAC",
          "languageCode": "en-US",
          "model": "latest_long"
        },
        "audio": {"content": base64},
      }),
    );
    log(response.statusCode.toString());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final   transcript =
          data['results']?[0]?['alternatives']?[0]?['transcript'];

      if (transcript != null) log('got transcription');
      log(transcript.toString());

      return transcript;
    } else {
      print("Error: ${response.statusCode}");
      log(response.body);
      return null;
    }
  }
}
