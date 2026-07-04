import 'interview_session_details.dart';

class InterviewQuestionBudget {
  const InterviewQuestionBudget({
    required this.minQuestions,
    required this.maxQuestions,
  });

  final int minQuestions;
  final int maxQuestions;

  factory InterviewQuestionBudget.fromDetails(InterviewSessionDetails details) {
    final difficulty = details.difficultyLevel.trim().toLowerCase();
    final interviewType = details.interviewType.trim().toLowerCase();
    final experience = details.yearsOfExperience.trim().toLowerCase();

    var minQuestions = 6;
    var maxQuestions = 8;

    if (difficulty.contains('medium')) {
      minQuestions = 7;
      maxQuestions = 9;
    } else if (difficulty.contains('hard')) {
      minQuestions = 8;
      maxQuestions = 10;
    }

    if (interviewType.contains('system')) {
      minQuestions = (minQuestions - 1).clamp(6, 10);
    }

    if (_isExperiencedCandidate(experience)) {
      maxQuestions = (maxQuestions + 1).clamp(minQuestions, 10);
    }

    return InterviewQuestionBudget(
      minQuestions: minQuestions,
      maxQuestions: maxQuestions,
    );
  }

  static bool _isExperiencedCandidate(String experience) {
    return experience.contains('3') ||
        experience.contains('4') ||
        experience.contains('5') ||
        experience.contains('senior') ||
        experience.contains('lead');
  }
}
