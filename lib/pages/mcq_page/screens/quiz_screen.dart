// ============================================================================
// QUIZ SCREEN - Multiple Choice Question Test
// ============================================================================
// Interactive quiz interface for quick interview assessment
// 
// FEATURES:
// 1. Multiple choice questions with instant feedback
// 2. Visual indication of correct/incorrect answers
// 3. Score tracking throughout the quiz
// 4. Progress through questions sequentially
// 5. Final score display at the end
// 
// FLOW:
// 1. Display question with multiple options
// 2. User selects an answer
// 3. Show visual feedback (correct = green, incorrect = red)
// 4. User clicks "Next" to proceed
// 5. Repeat until all questions answered
// 6. Navigate to result screen with final score
// 
// STATE MANAGEMENT:
// - Uses local state (StatefulWidget) instead of BLoC
// - Simple enough to not require complex state management
// 
// TODO: Add timer for each question
// TODO: Implement question shuffling for variety
// TODO: Add difficulty levels
// TODO: Store quiz history and progress
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/mcq_page/models/questions.dart';
import 'package:interview_app/pages/mcq_page/widgets/answer_card.dart';
import 'package:interview_app/pages/mcq_page/widgets/next_button.dart';

/// Quiz screen displaying multiple choice questions
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Currently selected answer index (null if no answer selected)
  int? selectedAnswerIndex;
  
  // Current question index (0-based)
  int questionIndex = 0;
  
  // Total score (number of correct answers)
  int score = 0;

  /// Handles answer selection
  /// Updates selected answer and increments score if correct
  void pickAnswer(int value) {
    selectedAnswerIndex = value;
    final question = questions[questionIndex];
    
    // Check if selected answer is correct
    if (selectedAnswerIndex == question.correctAnswerIndex) {
      score++;
    }
    setState(() {});
  }

  /// Navigates to next question
  /// Resets selected answer for new question
  void goToNextQuestion() {
    if (questionIndex < questions.length - 1) {
      questionIndex++;
      selectedAnswerIndex = null; // Reset selection for next question
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[questionIndex];
    bool isLastQuestion = questionIndex == questions.length - 1;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page'),
        backgroundColor: const Color.fromARGB(255, 245, 206, 114),
      ),
      backgroundColor: const Color.fromARGB(221, 113, 113, 112),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Display current question text
                Text(
                  question.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Display answer options
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      // Only allow selection if no answer selected yet
                      onTap: selectedAnswerIndex == null
                          ? () => pickAnswer(index)
                          : null,
                      child: AnswerCard(
                        currentIndex: index,
                        question: question.options[index],
                        isSelected: selectedAnswerIndex == index,
                        selectedAnswerIndex: selectedAnswerIndex,
                        correctAnswerIndex: question.correctAnswerIndex,
                      ),
                    );
                  },
                ),
                
                // Show "Finish" button on last question, "Next" otherwise
                // Next Button:
                isLastQuestion
                    ? RectangularButton(
                        onPressed: () {
                          // Navigate to result screen with final score
                          context.go('/result/$score');
                        },
                        label: 'Finish',
                      )
                    : RectangularButton(
                        // Only enable Next button after answer is selected
                        onPressed: selectedAnswerIndex != null
                            ? goToNextQuestion
                            : null,
                        label: 'Next',
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
