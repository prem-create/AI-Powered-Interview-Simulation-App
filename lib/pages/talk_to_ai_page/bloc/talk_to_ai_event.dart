part of 'talk_to_ai_bloc.dart';

@immutable
sealed class TalkToAiEvent {}

class SendButtonTappedEvent extends TalkToAiEvent {
  final String message;

  SendButtonTappedEvent({required this.message});
}

class ChatStratedEvent extends TalkToAiEvent {}