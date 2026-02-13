// ============================================================================
// ANSWER CARD - Quiz Answer Option Widget
// ============================================================================
// Displays a single answer option in the quiz with visual feedback
// 
// VISUAL LOGIC:
// Before selection:
//   - All cards have default style (white border, dark background)
//   - All cards are tappable
// 
// After selection:
//   - All cards become non-tappable
//   - Correct answer: Green border + checkmark icon
//   - Wrong answer (if selected): Red border + X icon
//   - Other options: Default style
// 
// FEATURES:
// - Visual feedback for correct/incorrect answers
// - Icons to indicate right/wrong choices
// - Responsive to selection state
// - Clean, readable design
// 
// TODO: Add animation when answer is revealed
// TODO: Add haptic feedback on selection
// TODO: Make colors customizable via theme
// ============================================================================

import 'package:flutter/material.dart';

/*
  If (no options is chosen)
    all answer cards should have default style
    all buttons should be enabled
  else
    all button should be disabled
    if (correct option is chosen)
      answer should be highlighted as green
    else
      answer should be highlighted as red
      correct answer should be highlighted as green
*/

/// Widget displaying a single quiz answer option
class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.question,
    required this.isSelected,
    required this.currentIndex,
    required this.correctAnswerIndex,
    required this.selectedAnswerIndex,
  });

  final String question; // Answer text
  final bool isSelected; // Is this option selected by user
  final int? correctAnswerIndex; // Index of correct answer
  final int? selectedAnswerIndex; // Index of user's selection
  final int currentIndex; // This card's index

  @override
  Widget build(BuildContext context) {
    // Determine if this is the correct answer
    bool isCorrectAnswer = currentIndex == correctAnswerIndex;
    // Determine if this is a wrong answer that was selected
    bool isWrongAnswer = !isCorrectAnswer && isSelected;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      child: selectedAnswerIndex != null
          // if one option is chosen
          // Show feedback with colors and icons
          ? Container(
              height: 70,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  // Green for correct, red for wrong, default for others
                  color: isCorrectAnswer
                      ? Colors.green
                      : isWrongAnswer
                          ? Colors.red
                          : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Show checkmark for correct, X for wrong
                  isCorrectAnswer
                      ? buildCorrectIcon()
                      : isWrongAnswer
                          ? buildWrongIcon()
                          : const SizedBox.shrink(),
                ],
              ),
            )
          // If no option is selected
          // Show default style for all options
          : Container(
              height: 70,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(26, 19, 14, 14),//option background
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white24//border option
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style:  TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Builds green checkmark icon for correct answer
Widget buildCorrectIcon() => const CircleAvatar(
      radius: 15,
      backgroundColor: Colors.green,
      child: Icon(
        Icons.check,
        color: Colors.white,
      ),
    );

/// Builds red X icon for wrong answer
Widget buildWrongIcon() => const CircleAvatar(
      radius: 15,
      backgroundColor: Colors.red,
      child: Icon(
        Icons.close,
        color: Colors.white,
      ),
    );
