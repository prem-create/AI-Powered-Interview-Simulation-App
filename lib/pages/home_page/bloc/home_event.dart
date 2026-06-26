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





