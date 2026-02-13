// ============================================================================
// RESULT SCREEN - Quiz Score Display
// ============================================================================
// Shows final quiz results with visual feedback
// 
// FEATURES:
// 1. Displays total score (correct answers)
// 2. Shows percentage score
// 3. Circular progress indicator for visual feedback
// 4. Navigation back to home page
// 
// VISUAL DESIGN:
// - Circular progress bar showing completion percentage
// - Large score display in center
// - Percentage calculation below score
// 
// TODO: Add detailed breakdown of correct/incorrect answers
// TODO: Show which questions were answered incorrectly
// TODO: Add option to retake quiz
// TODO: Implement score history and analytics
// TODO: Add social sharing for scores
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';
import 'package:interview_app/pages/mcq_page/models/questions.dart';
// import '/screens/quiz_screen.dart';
// import '/widgets/next_button.dart';

/// Result screen displaying quiz score and performance
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.score});

  final int score; // Number of correct answers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCORE PAGE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Custom back button to navigate to home
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: const Color.fromARGB(255, 245, 206, 114),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 97, 98, 100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Score: ',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w500),
            ),
            30.ht, // Extension method for SizedBox height
            
            // Circular progress indicator with score display
            Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress bar
                SizedBox(
                  height: 250,
                  width: 250,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    value: score / 9, // Progress value (0.0 to 1.0)
                    color: Colors.green, // Progress color
                    backgroundColor: Colors.white, // Background track color
                  ),
                ),
                // Score display in center of circle
                Column(
                  children: [
                    // Raw score (e.g., "7")
                    Text(
                      score.toString(),
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 10),
                    // Percentage score (e.g., "78%")
                    Text(
                      '${(score / questions.length * 100).round()}%',
                      style: const TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// 
