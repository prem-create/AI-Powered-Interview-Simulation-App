import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/talk_to_ai_page/bloc/talk_to_ai_bloc.dart';

class MessageSuccessPage extends StatelessWidget {
  final MessageSentSuccessState state;
  final TextEditingController candidateMessage;
  const MessageSuccessPage({super.key, required this.state, required this.candidateMessage,});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios_new_sharp),
                  ),
                  centerTitle: true,
                  title: Center(
                    child: Text(
                      'Chat with AI',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.responseMessage.length,
                          itemBuilder: (context, index) {
                            final message = state.responseMessage[index];
                            return Container(
                              alignment: message['isUser']
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              child: Container(
                                width: 300.w,
                                decoration: BoxDecoration(
                                  color: message['isUser']
                                      ? Colors.blueAccent
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  message['text'].toString(),
                                  style: TextStyle(
                                    color: message['isUser']
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 10.0),

                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                controller: candidateMessage,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  context.read<TalkToAiBloc>().add(
                                    SendButtonTappedEvent(
                                      message: candidateMessage.text,
                                    ),
                                  );
                                  candidateMessage.clear();
                                },
                              ),
                            ),

                            IconButton(
                              icon: Icon(Icons.send),
                              iconSize: 35,
                              onPressed: () => context.read<TalkToAiBloc>().add(
                                SendButtonTappedEvent(
                                  message: candidateMessage.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
  }
}