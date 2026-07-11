import 'dart:developer';
import 'package:interview_app/core/utils/errors_handler.dart';
import 'package:interview_app/pages/camera_interview_page/repo/groq_stt_repo.dart';
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

class RecordedAudioFile {
  const RecordedAudioFile({required this.path, required this.duration});

  final String path;
  final Duration duration;
}

class TranscriptionResult {
  const TranscriptionResult._({this.transcript, this.errorMessage});

  const TranscriptionResult.success(String transcript)
    : this._(transcript: transcript);

  const TranscriptionResult.failure(String message)
    : this._(errorMessage: message);

  final String? transcript;
  final String? errorMessage;

  bool get isSuccess => transcript != null;
}

class SpeechRecordingLogic {
  static const Duration maxNonStreamingRecordingDuration = Duration(minutes: 1);

  final recorder = AudioRecorder();
  final GroqSttRepo groqSttRepo = GroqSttRepo();
  DateTime? _recordingStartedAt;

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
      _recordingStartedAt = DateTime.now();

      return RecordingStartResult.success(path);
    } catch (error, stackTrace) {
      log('Unable to start recording', error: error, stackTrace: stackTrace);
      return const RecordingStartResult.failure(
        RecordingStartFailure.unavailable,
      );
    }
  }

  Future<String?> stopRecording() async {
    final audioFile = await stopRecordingToFile();
    if (audioFile == null) {
      return null;
    }

    final result = await transcribeRecording(audioFile);
    return result.transcript;
  }

  Future<RecordedAudioFile?> stopRecordingToFile() async {
    if (!await recorder.isRecording()) {
      return null;
    }

    final filePath = await recorder.stop();
    final duration = _recordingStartedAt == null
        ? Duration.zero
        : DateTime.now().difference(_recordingStartedAt!);
    _recordingStartedAt = null;
    log("Returned path: $filePath");

    if (filePath == null) {
      return null;
    }

    return RecordedAudioFile(path: filePath, duration: duration);
  }

  Future<TranscriptionResult> transcribeRecording(
    RecordedAudioFile audioFile,
  ) async {
    if (audioFile.duration > maxNonStreamingRecordingDuration) {
      return TranscriptionResult.failure(
        ErrorsHandler.groqSttRecordingTooLongMessage(),
      );
    }

    final file = File(audioFile.path);

    final exists = await file.exists();
    log("File exists: $exists");

    if (!exists) {
      return TranscriptionResult.failure(
        ErrorsHandler.groqSttFileUnavailableMessage(),
      );
    }

    final transcript = await groqSttRepo.transcribe(file: file);
    if (!transcript.isSuccess) {
      return TranscriptionResult.failure(
        transcript.errorMessage ?? ErrorsHandler.groqSttEmptyResponseMessage(),
      );
    }

    return TranscriptionResult.success(transcript.data!);
  }

  Future<void> cancelRecording() async {
    if (await recorder.isRecording()) {
      await recorder.cancel();
    }
    _recordingStartedAt = null;
  }

  Future<void> dispose() async {
    await cancelRecording();
    await recorder.dispose();
  }
}
