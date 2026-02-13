// ============================================================================
// HOME PAGE - Landing Screen with Feature Selection
// ============================================================================
// This is the main landing page where users choose their interview practice mode
// 
// FEATURES AVAILABLE:
// 1. Camera Interview - AI-powered interview with voice interaction
// 2. Talk to AI - Text-based chat interview practice
// 3. MCQ Quiz - Multiple choice question assessment
// 
// STATE MANAGEMENT: Uses BLoC pattern
// - HomeBloc manages navigation events and API key validation
// - Responsive design adapts to mobile/tablet/desktop screens
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:interview_app/pages/home_page/bloc/home_bloc.dart';
import 'package:interview_app/pages/home_page/ui/desktop_ui/desktop_view.dart';
import 'package:interview_app/pages/home_page/ui/mobile_ui/mobile_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// Home page widget - entry point of the application
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // BlocProvider: Creates and provides HomeBloc to the widget tree
    return BlocProvider(
      create: (context) {
        final bloc = HomeBloc();
        // Trigger API key validation event on page load
        // This ensures Gemini API is configured before user starts interview
        bloc.add(ApiKeyEvent());
        return bloc;
      },
      // ScreenTypeLayout: Renders different UI based on device type
      // Ensures optimal user experience across mobile, tablet, and desktop
      child: ScreenTypeLayout.builder(
        mobile: (context) => MobileView(), // Optimized for phones
        desktop: (_) => DesktopView(), // Optimized for larger screens
        // TODO: Add tablet-specific layout for better iPad experience
      ),
    );
  }
}
