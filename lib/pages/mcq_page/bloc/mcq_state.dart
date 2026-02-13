// ============================================================================
// MCQ STATES - Quiz UI States (Currently Unused)
// ============================================================================
// Defines states for MCQ quiz feature
// 
// CURRENT STATUS: Not actively used
// Only initial state defined as quiz uses local state management
// 
// TODO: Add states when implementing BLoC:
// - QuizLoadingState - Loading questions
// - QuizReadyState - Questions loaded, ready to start
// - QuestionDisplayState - Showing current question
// - AnswerSelectedState - User selected an answer
// - QuizCompletedState - All questions answered
// - QuizErrorState - Error loading questions
// ============================================================================

part of 'mcq_bloc.dart';

@immutable
sealed class McqState {}

/// Initial state before quiz starts
final class McqInitial extends McqState {}
