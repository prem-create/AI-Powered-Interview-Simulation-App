import 'dart:convert';
import 'dart:developer';
import 'package:interview_app/pages/camera_interview_page/repo/google_stt_repo.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

enum RecordingStartFailure { permissionDenied, unavailable }

class RecordingStartResult {
  const RecordingStartResult._({this.path, this.failure});

  const RecordingStartResult.success(String path) : this._(path: path);

  const RecordingStartResult.failure(RecordingStartFailure failure)
    : this._(failure: failure);

  final String? path;
  final RecordingStartFailure? failure;

  bool get isSuccess => path != null;
}

class SpeechRecordingLogic {
  final recorder = AudioRecorder();
  final GoogleSttRepo googleSttRepo = GoogleSttRepo();

  final recordConfig = const RecordConfig(
    encoder: AudioEncoder.flac,
    sampleRate: 16000,
    numChannels: 1,
  );

  Future<RecordingStartResult> startRecording() async {
    try {
      if (!await recorder.hasPermission()) {
        return const RecordingStartResult.failure(
          RecordingStartFailure.permissionDenied,
        );
      }

      final directory = await getApplicationDocumentsDirectory();

      final path = '${directory.path}/speech.flac';

      await recorder.start(recordConfig, path: path);

      return RecordingStartResult.success(path);
    } catch (error, stackTrace) {
      log('Unable to start recording', error: error, stackTrace: stackTrace);
      return const RecordingStartResult.failure(
        RecordingStartFailure.unavailable,
      );
    }
  }

  Future<String?> stopRecording() async {
    if (!await recorder.isRecording()) {
      return null;
    }

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

      final transcript = await googleSttRepo.sendToGoogleStt(base64: base64);
      return transcript;
    }
    return null;
  }

  Future<void> cancelRecording() async {
    if (await recorder.isRecording()) {
      await recorder.cancel();
    }
  }

  Future<void> dispose() async {
    await cancelRecording();
    await recorder.dispose();
  }
}
