class InterviewHistoryItem {
  const InterviewHistoryItem({
    required this.id,
    required this.candidateName,
    required this.interviewTopic,
    required this.difficultyLevel,
    required this.interviewType,
    required this.yearsOfExperience,
    required this.status,
    required this.answeredQuestionsCount,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.resultMarkdown,
  });

  final String id;
  final String candidateName;
  final String interviewTopic;
  final String difficultyLevel;
  final String interviewType;
  final String yearsOfExperience;
  final String status;
  final int answeredQuestionsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? resultMarkdown;

  bool get hasResult =>
      resultMarkdown != null && resultMarkdown!.trim().isNotEmpty;
}
