// ============================================================================
// MAIN ENTRY POINT - AI Interview Coach Application
// ============================================================================
// This is the root of the entire application. The app flow starts here.
//
// APP ARCHITECTURE OVERVIEW:
// 1. Main Entry (this file) → Initializes the app with routing and responsive design
// 2. Routes (routes.dart) → Defines navigation paths between screens
// 3. Home Page → Landing page with three main features:
//    - Camera Interview (AI-powered interview with TTS)
//    - Talk to AI (Chat-based interview practice)
//    - MCQ Quiz (Multiple choice questions)
// 4. Each feature uses BLoC pattern for state management
// 5. Gemini AI integration for intelligent interview simulation
// ============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview_app/core/constants/constants.dart';
import 'package:interview_app/firebase_options.dart';
import 'package:interview_app/routes/routes.dart';

/// Application entry point - called when the app starts
void main() async {
  // it is needed to run once before using runApp, firebase needed it 
  WidgetsFlutterBinding.ensureInitialized();
  // initializing fire base by using firebase option files
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _loadRemoteConfig();
  runApp(const MainApp());
}

Future<void> _loadRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
 
  // How often the app checks Firebase for updated keys
  // 1 hour is good for production — during testing use Duration(minutes: 1)
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));
 
  // Set fallback values — if Firebase is unreachable, these are used
  // Leave them empty for now, you'll handle the empty case below
  await remoteConfig.setDefaults({'gemini_api_key': '', 'stt_api_key': ''});
 
  // Fetch latest values from Firebase and activate them
  await remoteConfig.fetchAndActivate();
 
  // Store in your existing global variables — rest of app works unchanged
  geminiApiKey = remoteConfig.getString('gemini_api_key');
  googleCloudSttApiKey = remoteConfig.getString('stt_api_key');
}


/// Root widget of the application
/// Sets up responsive design and routing configuration
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit: Enables responsive design across different screen sizes
    // Design size based on standard mobile dimensions (390x1002)
    return ScreenUtilInit(
      designSize: Size(390, 1002), // Base design dimensions for scaling
      splitScreenMode: true, // Supports split-screen mode on tablets
      builder: (_, child) => MaterialApp.router(
        debugShowCheckedModeBanner:
            false, // Removes debug banner in development
        routerConfig: router, // Uses GoRouter for declarative navigation
      ),
    );
  }
}
