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

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/auth/auth_page.dart';
import 'package:interview_app/pages/auth/repo/auth_repository.dart';
import 'package:interview_app/pages/camera_interview_page/ui/camera_interview.dart';
import 'package:interview_app/pages/resutl_History_page/histroy_page.dart';
import 'package:interview_app/pages/resutl_History_page/result_history_page.dart';
import 'package:interview_app/pages/talk_to_ai_page/ui/start_talk_to_ai.dart';
import 'package:interview_app/pages/home_page/ui/home.dart';

final AuthRepository _authRepository = AuthRepository();

/// Global router instance used by MaterialApp.router
final GoRouter router = GoRouter(
  initialLocation: '/', // App starts at home page
  refreshListenable: _AuthStateRefreshListenable(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final isLoginRoute = state.uri.path == '/';
    final isLoggedIn = _authRepository.isLoggedIn;
    final user = FirebaseAuth.instance.currentUser;
    final isEmailVerified = user?.emailVerified ?? false;

    // If logged in but email not verified, force back to auth page
    if (isLoggedIn && !isEmailVerified) {
      return '/';
    }

    if (!isLoggedIn && !isLoginRoute) {
      return '/';
    }

    if (isLoginRoute && isLoggedIn && isEmailVerified) {
      return '/home';
    }

    return null;
  },
  routes: [
    // ========== HOME PAGE ROUTE ==========
    // Landing page - entry point after app launch
    GoRoute(path: '/', builder: (context, state) => const AuthPage()),
    GoRoute(path: '/home', builder: (context, state) => const Home()),

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
    GoRoute(
      path: '/resultHistory',
      builder: (context, state) => const ResultHistoryPage(),
    ),
    GoRoute(
      path: '/historyPage',
      builder: (context, state) {
        final result = state.extra as String;
        return HistroyPage(result: result);
      },
    ),
  ],
);

class _AuthStateRefreshListenable extends ChangeNotifier {
  _AuthStateRefreshListenable(Stream<User?> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
