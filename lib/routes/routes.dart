// ============================================================================
// ROUTING CONFIGURATION - Navigation Structure
// ============================================================================
// Defines all navigation routes in the application using GoRouter
// 
// NAVIGATION FLOW:
// 1. Home (/) → Landing page with three options
// 2. Camera Interview (/CameraInterview) → AI interview with TTS/STT
// 3. Talk to AI (/startTalkToAi) → Chat-based interview practice
// 4. MCQ Quiz (/Mcq) → Multiple choice question test
// 5. Result (/result/:score) → Quiz result display with score parameter
// 
// TODO: Implement camera interview result page for detailed feedback
// ============================================================================

import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/camera_interview_page/ui/camera_interview.dart';
import 'package:interview_app/pages/mcq_page/screens/quiz_screen.dart';
import 'package:interview_app/pages/mcq_page/screens/result_screen.dart';
import 'package:interview_app/pages/talk_to_ai_page/ui/start_talk_to_ai.dart';
import 'package:interview_app/pages/home_page/ui/home.dart';

/// Global router instance used by MaterialApp.router
final GoRouter router = GoRouter(
  initialLocation: '/', // App starts at home page
  routes: [
    // ========== HOME PAGE ROUTE ==========
    // Landing page - entry point after app launch
    GoRoute(
      path: '/',
      builder: (context, state) => const Home(),
    ),
    
    // ========== CAMERA INTERVIEW ROUTE ==========
    // AI-powered interview with text-to-speech and speech-to-text
    // Features: Real-time AI questions, voice interaction, performance evaluation
    GoRoute(
      path: '/CameraInterview',
      builder: (context, state) => const CameraInterview(),
    ),
    
    // ========== TALK TO AI ROUTE ==========
    // Chat-based interview practice with conversational AI
    // Features: Text-based Q&A, contextual follow-ups, casual interview prep
    GoRoute(
      name: 'talk-to-ai',
      path: '/startTalkToAi',
      builder: (context, state) => const StartTalkToAi(),
    ),
    
    // ========== MCQ QUIZ ROUTE ==========
    // Multiple choice question test for quick assessment
    // Features: Timed questions, instant feedback, score tracking
    GoRoute(
      name: 'Mcq',
      path: '/Mcq',
      builder: (context, state) => const QuizScreen(),
    ),
    
    // ========== RESULT PAGE ROUTE ==========
    // Displays quiz results with score percentage and visual feedback
    // Path parameter: score (integer) - number of correct answers
    GoRoute(
      path: '/result/:score',
      builder: (context, state) {
        final score = int.parse(state.pathParameters['score']!);
        return ResultScreen(score: score);
      },
    ),
    
    // TODO: Implement dedicated result page for camera interview
    // Should include: detailed feedback, strengths/weaknesses, improvement suggestions
    // GoRoute(
    //   name: 'cameraInterviewResultPage',
    //   path: '/cameraInterviewResultPage',
    //   builder: (context, state) => const CameraInterviewResultPage(result: state,),
    // ),
  ],
);
