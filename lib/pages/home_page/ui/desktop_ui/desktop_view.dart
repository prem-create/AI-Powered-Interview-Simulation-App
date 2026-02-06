//desktop view
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/home_page/ui/utils/my_custom_card.dart';

class DesktopView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color.fromRGBO(234, 240, 249, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              MyCustomCard(
                title: 'Camera Interview',
                description:
                    "Practice live interviews with AI, focusing on visual cues and real-time feedback. Get personalized suggestions for improvement",
                buttonText: 'Start camera interveiw',
                buttoncolor: const Color(0xFF3F51B5),
                icon: Icons.camera_alt_outlined,
                backgroundColor: const Color.fromARGB(255, 219, 226, 246),
                onPressed: () => context.push('/CameraInterview'),
              ),

              MyCustomCard(
                title: 'Talk to AI',
                description:
                    'Engage in voice or chat-based conversations with AI for flexible practice sessions. Refine your verbal responses.',
                buttonText: 'Start Talk to AI',
                buttoncolor: const Color(0xFF25D1F4),
                icon: Icons.mic,
                backgroundColor: const Color.fromARGB(255, 219, 226, 246),
                onPressed: () {},
              ),

              MyCustomCard(
                title: 'MCQ',
                description:
                    'Test your knowledge with AI-generated multiple-choice questions on various topics. Strengthen your theoretical understanding.',
                buttonText: 'Start MCQ Session',
                buttoncolor: const Color.fromARGB(255, 85, 132, 253),
                icon: Icons.list,
                backgroundColor: const Color.fromARGB(255, 219, 226, 246),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
