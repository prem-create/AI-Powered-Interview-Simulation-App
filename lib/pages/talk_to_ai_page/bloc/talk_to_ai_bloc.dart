// ============================================================================
// TALK TO AI BLOC - Chat Session Management
// ============================================================================
// Manages state and logic for text-based AI chat feature
// 
// RESPONSIBILITIES:
// 1. Initialize chat with welcome message
// 2. Handle user message sending
// 3. Maintain chat history for UI display
// 4. Communicate with Gemini AI for responses
// 
// CHAT FLOW:
// 1. ChatStartedEvent → Initialize chat, get welcome message
// 2. SendButtonTappedEvent → Send user message, get AI reply
// 3. Update chat history with both messages
// 4. Emit success state to update UI
// 
// STATE MANAGEMENT:
// - _chatMessage: Local list of all messages for UI display
// - GeminiRepository: Maintains conversation context for AI
// ============================================================================

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:interview_app/pages/talk_to_ai_page/repos/gemini_repository.dart';

import 'package:meta/meta.dart';

part 'talk_to_ai_event.dart';
part 'talk_to_ai_state.dart';

/// BLoC for managing chat-based AI interview feature
class TalkToAiBloc extends Bloc<TalkToAiEvent, TalkToAiState> {
  // Repository for Gemini AI communication
  final GeminiRepository _geminiRepository = GeminiRepository();
  
  // Chat history for UI display
  // Format: [{'text': 'message', 'isUser': true/false}]
  final List<Map<String, dynamic>> _chatMessage = [];

  TalkToAiBloc() : super(TalkToAiInitial()) {
    // Register event handlers
    on<SendButtonTappedEvent>(sendButtonTappedEvent);
    on<ChatStratedEvent>(chatStratedEvent);
  }

  /// Handles user message send event
  /// FLOW:
  /// 1. Validate message is not empty
  /// 2. Show loading state with current messages
  /// 3. Add user message to chat history
  /// 4. Send to AI and get response
  /// 5. Add AI response to chat history
  /// 6. Emit success state with updated messages
  FutureOr<void> sendButtonTappedEvent(
    SendButtonTappedEvent event,
    Emitter<TalkToAiState> emit,
  ) async {
    // Ignore empty messages
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

  /// Handles chat initialization event
  /// Triggered when page loads to send welcome message from AI
  FutureOr<void> chatStratedEvent(
    ChatStratedEvent event,
    Emitter<TalkToAiState> emit,
  ) async {
    // Show loading state
    emit(TalkToAiLoadingState(responseMessage: List.from(_chatMessage)));
    
    // Initialize chat with AI (sets up conversational prompt)
    _geminiRepository.startChat();
    
    // Get welcome message from AI
    final welcomeMessage = await _geminiRepository.sendToGemini();
    
    // Add welcome message to chat history
    _chatMessage.add({'text': welcomeMessage, 'isUser': false});
    
    // Display chat interface with welcome message
    emit(MessageSentSuccessState(responseMessage: List.from(_chatMessage)));
  }
}
