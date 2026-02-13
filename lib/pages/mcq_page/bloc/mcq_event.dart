// ============================================================================
// MCQ EVENTS - Quiz User Actions (Currently Unused)
// ============================================================================
// Defines events for MCQ quiz feature
// 
// CURRENT STATUS: Not actively used
// No events defined yet as quiz uses local state management
// 
// TODO: Add events when implementing BLoC:
// - AnswerSelectedEvent - User selects an answer
// - NextQuestionEvent - User moves to next question
// - QuizStartedEvent - Quiz begins
// - QuizCompletedEvent - All questions answered
// - QuizResetEvent - Restart quiz
// ============================================================================

part of 'mcq_bloc.dart';

@immutable
sealed class McqEvent {}
