import 'dart:convert';
import 'dart:developer';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/repo/google_stt_repo.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SpeechRecordingLogic  {
  final recorder = AudioRecorder();
  final GoogleSttRepo googleSttRepo = GoogleSttRepo();

  final recordConfig = const RecordConfig(
    encoder: AudioEncoder.flac,
    sampleRate: 16000,
    numChannels: 1,
  );

  Future<String?> startRecording() async {
    if (await recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();

      final path = '${directory.path}/speech.flac';

      await recorder.start(recordConfig, path: path);

      return path;
    }

    return null;
  }

  Future<String?> stopRecording() async {
    final filePath = await recorder.stop();
    log("Returned path: $filePath");

    if (filePath != null) {
      final file = File(filePath);

      final exists = await file.exists();
      log("File exists: $exists");

      // read as bytes
      final bytes = await file.readAsBytes();

      //conver to base64
      final base64 = base64Encode(bytes);
      log("Base64 length: ${base64.length}");

      final  transcript = await googleSttRepo.sendToGoogleStt(base64: base64);
      return transcript;
    }
    return null;
  }
}
