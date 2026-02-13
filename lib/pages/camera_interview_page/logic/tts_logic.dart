import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';


class TtsLogic {
  //single tts instance for all
  FlutterTts tts = FlutterTts();

  String Language = '';
  double pitch = 1;
  double rate = 1;
  double volume = 1;

  //TTS Function
  void initializeTts() {
    WidgetsBinding.instance.addPostFrameCallback((_) => initLanguages());
  }

  void initLanguages() async {
    Language = await tts.getDefaultEngine ?? 'Eng-Us';
    log(Language);
  }

  void speak({required final String text}) {
    tts.speak(text);
  }

  void stopSpeaking() {
    tts.stop();
  }
}
