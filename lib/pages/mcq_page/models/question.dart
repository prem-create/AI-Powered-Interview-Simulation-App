// ============================================================================
// QUESTION MODEL - Data Structure for Quiz Questions
// ============================================================================
// Defines the structure of a single quiz question
// 
// STRUCTURE:
// - question: The question text
// - options: List of possible answers
// - correctAnswerIndex: Index of the correct answer in options array
// 
// USAGE:
// Used by quiz screen to display questions and validate answers
// Questions are defined in questions.dart file
// 
// TODO: Add additional fields:
// - difficulty: Easy/Medium/Hard
// - category: Topic/subject area
// - explanation: Why the answer is correct
// - timeLimit: Seconds allowed for this question
// - points: Score value for this question
// ============================================================================

/// Model representing a single quiz question
class Question {
  final String question; // The question text
  final List<String> options; // Array of possible answers
  final int correctAnswerIndex; // Index of correct answer (0-based)

  const Question({
    required this.correctAnswerIndex,
    required this.question,
    required this.options,
  });
}
