import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:text_to_speech/text_to_speech.dart';

class TtsLogic {
  //single tts instance for all
  TextToSpeech tts = TextToSpeech();

  String Language = '';
  double pitch = 1;
  double rate = 1;
  double volume = 1;

  //TTS Function
  void initializeTts() {
    WidgetsBinding.instance.addPostFrameCallback((_) => initLanguages());
  }

  void initLanguages() async {
    Language = await tts.getDefaultLanguage() ?? 'Eng-Us';
    log(Language);
  }

  void speak({required final String text}) {
    tts.speak(text);
  }

  void stopSpeaking() {
    tts.stop();
  }
}
