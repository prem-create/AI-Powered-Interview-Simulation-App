// ============================================================================
// TTS LOGIC - Text-to-Speech Functionality
// ============================================================================
// Handles text-to-speech conversion for AI interview questions
// Makes the interview more realistic by speaking questions aloud
// 
// FEATURES:
// 1. Initialize TTS engine with default settings
// 2. Speak text with customizable voice parameters
// 3. Stop ongoing speech
// 
// USAGE:
// - Called by CameraInterviewBloc when AI question is received
// - Speaks questions automatically for immersive interview experience
// 
// TODO: Add voice selection (male/female voices)
// TODO: Implement adjustable speech rate and pitch controls
// TODO: Add language selection for multilingual interviews
// TODO: Cache TTS instance to avoid re-initialization
// ============================================================================

import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';


/// Manages text-to-speech functionality for interview questions
class TtsLogic {
  //single tts instance for all
  FlutterTts tts = FlutterTts();

  // TTS configuration parameters
  String Language = ''; // Language code (e.g., 'en-US')
  double pitch = 1; // Voice pitch (0.5 to 2.0)
  double rate = 1; // Speech rate/speed (0.0 to 1.0)
  double volume = 1; // Volume level (0.0 to 1.0)

  //TTS Function
  /// Initializes the TTS engine with default language
  /// Called before speaking to ensure engine is ready
  void initializeTts() {
    WidgetsBinding.instance.addPostFrameCallback((_) => initLanguages());
  }

  /// Gets and sets the default language for TTS
  /// Falls back to 'Eng-Us' if no default engine found
  void initLanguages() async {
    Language = await tts.getDefaultEngine ?? 'Eng-Us';
    log(Language);
  }

  /// Speaks the provided text aloud
  /// Used to vocalize AI interview questions
  void speak({required final String text}) {
    tts.speak(text);
  }

  /// Stops any ongoing speech
  /// Called when user submits answer to prevent overlap
  void stopSpeaking() {
    tts.stop();
  }
}
