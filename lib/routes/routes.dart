import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/camera_interview_page/ui/camera_interview.dart';
import 'package:interview_app/pages/camera_interview_page/ui/mobile_ui/camera_interview_result_page.dart';
import 'package:interview_app/pages/mcq_page/screens/quiz_screen.dart';
import 'package:interview_app/pages/mcq_page/screens/result_screen.dart';
import 'package:interview_app/pages/talk_to_ai_page/ui/start_talk_to_ai.dart';
import 'package:interview_app/pages/home_page/ui/home.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Home(), // Point to your screen
    ),
    // In your routes file
    GoRoute(
      path: '/CameraInterview', // Ensure this has the '/'
      builder: (context, state) => const CameraInterview(),
    ),
    GoRoute(
      name: 'talk-to-ai', // Add a name
      path: '/startTalkToAi',
      builder: (context, state) => const StartTalkToAi(),
    ),
    GoRoute(
      name: 'Mcq', // Add a name
      path: '/Mcq',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/result/:score',
      builder: (context, state) {
        final score = int.parse(state.pathParameters['score']!);
        return ResultScreen(score: score);
      },
    ),
    // GoRoute(
    //   name: 'cameraInterviewResultPage',
    //   path: '/cameraInterviewResultPage',
    //   builder: (context, state) => const CameraInterviewResultPage(result: state,),
    // ),
  ],
);
