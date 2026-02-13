// ============================================================================
// TALK TO AI PAGE - Chat-Based Interview Practice
// ============================================================================
// Text-based conversational interview practice with AI
// 
// FEATURES:
// 1. Real-time chat interface with AI
// 2. Contextual conversation (AI remembers previous messages)
// 3. Casual interview preparation
// 4. No voice required - pure text interaction
// 
// FLOW:
// 1. Page loads → AI sends welcome message
// 2. User types message → Sends to AI
// 3. AI responds with contextual reply
// 4. Conversation continues with full context
// 
// DIFFERENCE FROM CAMERA INTERVIEW:
// - More casual, conversational tone
// - No TTS/STT - text only
// - No formal interview structure
// - Good for quick practice and Q&A
// 
// TODO: Add message history persistence (save/load conversations)
// TODO: Implement typing indicators for better UX
// TODO: Add message timestamps
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_app/pages/talk_to_ai_page/bloc/talk_to_ai_bloc.dart';
import 'package:interview_app/pages/talk_to_ai_page/ui/message_loading_page.dart';
import 'package:interview_app/pages/talk_to_ai_page/ui/message_success_page.dart';

/// Main page for text-based AI chat interview practice
class StartTalkToAi extends StatefulWidget {
  const StartTalkToAi({super.key});

  @override
  State<StartTalkToAi> createState() => _StartTalkToAiState();
}

class _StartTalkToAiState extends State<StartTalkToAi> {
  // Controller for user message input field
  TextEditingController candidateMessage = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = TalkToAiBloc();
        //initializing the chat with welcome message
        // Triggers AI to send greeting when page opens
        bloc.add(ChatStratedEvent());
        return bloc;
      },
      child: BlocConsumer<TalkToAiBloc, TalkToAiState>(
        // listenWhen: Only listen to action states (one-time events)
        listenWhen: (previous, current) => current is TalkToAiActionState,
        // buildWhen: Rebuild UI for regular states (not action states)
        buildWhen: (previous, current) => current is! TalkToAiActionState,
        listener: (context, state) {},
        builder: (context, state) {
          // Show loading state while waiting for AI response
          if (state is TalkToAiLoadingState) {
            return MessageLoadingPage(
              state: state ,
              candidateMessage: candidateMessage,
            );
          } 
          // Show chat interface with messages when AI responds
          else if (state is MessageSentSuccessState) {
            return MessageSuccessPage(
              state: state,
              candidateMessage: candidateMessage,
            );
          }
          //Error handling
          // Display error message if AI communication fails
          else if (state is TalkToAiErrorState) {
            return Scaffold(
              body: Center(child: Text('Error: ${state.errorMessage}')),
            );
          } 
          // Fallback for unexpected states
          else {
            return Scaffold(body: Center(child: Text("something went wrong!")));
          }
        },
      ),
    );
  }
}
