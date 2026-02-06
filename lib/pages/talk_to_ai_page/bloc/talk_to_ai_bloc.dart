import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:interview_app/pages/talk_to_ai_page/repos/gemini_repository.dart';

import 'package:meta/meta.dart';

part 'talk_to_ai_event.dart';
part 'talk_to_ai_state.dart';

class TalkToAiBloc extends Bloc<TalkToAiEvent, TalkToAiState> {
  final GeminiRepository _geminiRepository = GeminiRepository();
  final List<Map<String, dynamic>> _chatMessage = [];

  TalkToAiBloc() : super(TalkToAiInitial()) {
    on<SendButtonTappedEvent>(sendButtonTappedEvent);
    on<ChatStratedEvent>(chatStratedEvent);
  }

  FutureOr<void> sendButtonTappedEvent(
    SendButtonTappedEvent event,
    Emitter<TalkToAiState> emit,
  ) async {
    if (event.message.isEmpty) {
      return;
    }
    // STEP 1: Emit loading state
    emit(TalkToAiLoadingState(responseMessage: List.from(_chatMessage)));

    // STEP 2: Add user message to UI list
    _chatMessage.add({'text': event.message, 'isUser': true});

    // STEP 3: Send to gemini it automatically adds to memory
    final String? geminiResponse = await _geminiRepository.sendCandidateAnswer(
      event.message,
    );
    //Step 4: Add gemini response in chat message list
    _chatMessage.add({
      'text': geminiResponse ?? "Error: No response from AI.",
      'isUser': false,
    });
    // STEP 5: Emit success state with updated messages
    emit(MessageSentSuccessState(responseMessage: List.from(_chatMessage)));
  }

  FutureOr<void> chatStratedEvent(
    ChatStratedEvent event,
    Emitter<TalkToAiState> emit,
  ) async {
    emit(TalkToAiLoadingState(responseMessage: List.from(_chatMessage)));
    _geminiRepository.startChat();
    final welcomeMessage = await _geminiRepository.sendToGemini();
    _chatMessage.add({'text': welcomeMessage, 'isUser': false});
    emit(MessageSentSuccessState(responseMessage: List.from(_chatMessage)));
  }
}
