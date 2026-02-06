import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_app/pages/talk_to_ai_page/bloc/talk_to_ai_bloc.dart';
import 'package:interview_app/pages/talk_to_ai_page/ui/message_loading_page.dart';
import 'package:interview_app/pages/talk_to_ai_page/ui/message_success_page.dart';

class StartTalkToAi extends StatefulWidget {
  const StartTalkToAi({super.key});

  @override
  State<StartTalkToAi> createState() => _StartTalkToAiState();
}

class _StartTalkToAiState extends State<StartTalkToAi> {
  TextEditingController candidateMessage = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = TalkToAiBloc();
        //initializing the chat with welcome message
        bloc.add(ChatStratedEvent());
        return bloc;
      },
      child: BlocConsumer<TalkToAiBloc, TalkToAiState>(
        listenWhen: (previous, current) => current is TalkToAiActionState,
        buildWhen: (previous, current) => current is! TalkToAiActionState,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TalkToAiLoadingState) {
            return MessageLoadingPage(
              state: state ,
              candidateMessage: candidateMessage,
            );
          } else if (state is MessageSentSuccessState) {
            return MessageSuccessPage(
              state: state,
              candidateMessage: candidateMessage,
            );
          }
          //Error handling
          else if (state is TalkToAiErrorState) {
            return Scaffold(
              body: Center(child: Text('Error: ${state.errorMessage}')),
            );
          } else {
            return Scaffold(body: Center(child: Text("something went wrong!")));
          }
        },
      ),
    );
  }
}
