// ============================================================================
// TALK TO AI EVENTS - User Actions in Chat
// ============================================================================
// Defines all possible user interactions in the chat interface
// ============================================================================

part of 'talk_to_ai_bloc.dart';

@immutable
sealed class TalkToAiEvent {}

/// Event: User sends a message in the chat
/// Triggered when send button is tapped
class SendButtonTappedEvent extends TalkToAiEvent {
  final String message; // User's message text

  SendButtonTappedEvent({required this.message});
}

/// Event: Chat session started
/// Triggered when page loads to initialize conversation with AI
class ChatStratedEvent extends TalkToAiEvent {}
