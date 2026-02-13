// ============================================================================
// TALK TO AI STATES - Chat UI States
// ============================================================================
// Defines all possible states for the chat interface
// UI rebuilds based on these states to show messages, loading, or errors
// ============================================================================

part of 'talk_to_ai_bloc.dart';

@immutable
sealed class TalkToAiState {}

/// Initial state before chat starts
final class TalkToAiInitial extends TalkToAiState {}

/// Base class for action states (one-time events)
abstract class TalkToAiActionState extends TalkToAiState {}

/// State: Message sent successfully and AI responded
/// Contains full chat history to display in UI
final class MessageSentSuccessState extends TalkToAiState {
  final List<Map<String, dynamic>> responseMessage; // All messages in chat

  MessageSentSuccessState({required this.responseMessage});
}

/// State: Waiting for AI response
/// Shows loading indicator while maintaining current messages
final class TalkToAiLoadingState extends TalkToAiState {
  final List<Map<String, dynamic>> responseMessage; // Current messages

  TalkToAiLoadingState({required this.responseMessage});
}

/// State: Error occurred during AI communication
/// Displays error message to user
final class TalkToAiErrorState extends TalkToAiState {
  final String errorMessage; // Error description

  TalkToAiErrorState({required this.errorMessage});
}
