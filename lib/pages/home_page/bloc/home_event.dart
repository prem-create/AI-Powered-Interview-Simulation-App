// ============================================================================
// HOME EVENTS - User Actions on Home Page
// ============================================================================
// Defines all possible user interactions on the home page
// Events are dispatched when user clicks buttons or triggers actions
// ============================================================================

part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

/// Event: User clicked Camera Interview button
/// Triggers navigation to AI-powered interview with voice interaction
final class CameraInterviewButtonClicked extends HomeEvent {}

/// Event: User clicked Talk to AI button
/// Triggers navigation to text-based chat interview
final class StartTalkToAiButtonClicked extends HomeEvent {}

/// Event: User clicked MCQ Quiz button
/// Triggers navigation to multiple choice question test
final class StartMcqButtonClicked extends HomeEvent {}

/// Event: App needs to validate API key
/// Triggered on app startup to ensure Gemini API is configured
final class ApiKeyEvent extends HomeEvent {}

/// Event: API key validation completed successfully
/// Returns user to home screen after validation
final class ApiKeyRecievedEvent extends HomeEvent {}
