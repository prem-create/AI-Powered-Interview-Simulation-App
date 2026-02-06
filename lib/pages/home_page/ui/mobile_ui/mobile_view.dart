//mobile view
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/pages/home_page/bloc/home_bloc.dart';
import 'package:interview_app/pages/home_page/ui/utils/my_custom_card.dart';

class MobileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) => current is HomeActionState,
      buildWhen: (previous, current) => current is! HomeActionState,
      listener: (context, state) {
        if (state is CameraInterviewActionState) {
          context.push('/CameraInterview');
        } else if (state is StartTalkToAiActionState) {
          context.push('/startTalkToAi');
        } else if (state is McqActionState) {
          context.push('/Mcq');
        }
      },
      builder: (context, state) {
        final parentContext =context;
        if (state is ApiKeyState) {
          final TextEditingController apiKeyController =
              TextEditingController();
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                child: Text('start the demo'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Enter Your Api key"),
                    content: Text(
                      "Don't worry entering api key here is safe. Your api key won't be stored anywhere. it's just to bypass buying paid api from google cloud console for demo purpose.",
                    ),
                    actions: [
                      TextField(
                        controller: apiKeyController,
                        decoration: InputDecoration(
                          hintText: "Enter API Key",
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          apiKey = apiKeyController.text;
                          if(apiKey.isEmpty){
                            context.pop();
                          }else{
                            parentContext.read<HomeBloc>().add(ApiKeyRecievedEvent());
                            context.pop();
                          }
                        },
                        child: Text("OK"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        else if(state is HomeInitial){
          return Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: () {}, icon: Icon(Icons.person)),
            title: Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                "AI Interview Coach",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.white,
          ),
          backgroundColor: const Color.fromARGB(255, 234, 240, 249),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MyCustomCard(
                    title: 'Start Interview',
                    description:
                        "Practice live interviews with AI, focusing on visual cues and real-time feedback. Get personalized suggestions for improvement",
                    buttonText: 'Start camera interveiw',
                    buttoncolor: const Color(0xFF3F51B5),
                    icon: Icons.camera_alt_outlined,
                    backgroundColor: const Color.fromARGB(255, 219, 226, 246),
                    onPressed: () => context.read<HomeBloc>().add(
                      CameraInterviewButtonClicked(),
                    ),
                  ),

                  MyCustomCard(
                    title: 'Talk to AI',
                    description:
                        'Engage in voice or chat-based conversations with AI for flexible practice sessions. Refine your verbal responses.',
                    buttonText: 'Start Talk to AI',
                    buttoncolor: const Color(0xFF25D1F4),
                    icon: Icons.mic,
                    backgroundColor: const Color.fromARGB(255, 219, 226, 246),
                    onPressed: () => context.read<HomeBloc>().add(
                      StartTalkToAiButtonClicked(),
                    ),
                  ),
                  MyCustomCard(
                    title: 'MCQ',
                    description:
                        'Test your knowledge with AI-generated multiple-choice questions on various topics. Strengthen your theoretical understanding.',
                    buttonText: 'Start MCQ Session',
                    buttoncolor: const Color.fromARGB(255, 85, 132, 253),
                    icon: Icons.list,
                    backgroundColor: const Color.fromARGB(255, 219, 226, 246),
                    onPressed: () => context.read<HomeBloc>().add(
                      StartMcqButtonClicked(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
