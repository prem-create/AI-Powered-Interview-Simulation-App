part of 'talk_to_ai_bloc.dart';

@immutable
sealed class TalkToAiState {}

final class TalkToAiInitial extends TalkToAiState {}

abstract class TalkToAiActionState extends TalkToAiState {}

final class MessageSentSuccessState extends TalkToAiState {
  final List<Map<String, dynamic>> responseMessage;

  MessageSentSuccessState({required this.responseMessage});
}

final class TalkToAiLoadingState extends TalkToAiState {
  final List<Map<String, dynamic>> responseMessage;

  TalkToAiLoadingState({required this.responseMessage});
}

final class TalkToAiErrorState extends TalkToAiState {
  final String errorMessage;

  TalkToAiErrorState({required this.errorMessage});
}