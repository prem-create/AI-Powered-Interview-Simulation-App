// ============================================================================
// CAMERA INTERVIEW STATES - UI States During Interview
// ============================================================================
// Defines all possible states during the interview session
// UI rebuilds based on these states to show appropriate screens
// ============================================================================

part of 'camera_interview_bloc.dart';

@immutable
sealed class CameraInterviewState {}

/// Base class for action states (one-time actions like navigation)
abstract class CameraInterviewActionState extends CameraInterviewState {}

/// State: Initial state - shows interview details form
/// User enters name, topic, and difficulty level
final class CameraInterviewInitial extends CameraInterviewState {}

/// State: Interview started successfully (not currently used)
/// TODO: Consider removing if not needed
final class StartCameraInterviewButtonTappedSuccessState
    extends CameraInterviewState {}

/// State: Loading - waiting for AI response
/// Shows loading indicator while Gemini processes request
final class CameraInterviewLoadingState extends CameraInterviewState {}

/// State: Error occurred during AI communication
/// Shows error message to user
final class CameraInterviewLoadingErrorState extends CameraInterviewState {}

/// State: Successfully received question from AI
/// Displays question and enables TTS to speak it
final class CameraInterviewLoadingSuccessState extends CameraInterviewState {
  final String question; // AI-generated question to display and speak

  CameraInterviewLoadingSuccessState({required this.question});
}

/// Action State: Navigate back to interview details form
/// Triggered when user wants to restart interview
final class AskInterviewDetailsState extends CameraInterviewActionState {}

/// State: Interview ended - shows comprehensive performance report
/// Contains AI-generated feedback with strengths, weaknesses, and suggestions
final class CameraInterviewResultState extends CameraInterviewState {
  final String result; // Detailed performance evaluation from AI

  CameraInterviewResultState({required this.result});
}