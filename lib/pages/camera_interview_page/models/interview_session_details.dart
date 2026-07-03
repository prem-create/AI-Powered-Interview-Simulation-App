class InterviewSessionDetails {
  const InterviewSessionDetails({
    required this.candidateName,
    required this.interviewTopic,
    required this.difficultyLevel,
    required this.interviewType,
    required this.yearsOfExperience,
  });

  final String candidateName;
  final String interviewTopic;
  final String difficultyLevel;
  final String interviewType;
  final String yearsOfExperience;

  Map<String, dynamic> toMap() {
    return {
      'candidateName': candidateName.trim(),
      'interviewTopic': interviewTopic.trim(),
      'difficultyLevel': difficultyLevel,
      'interviewType': interviewType,
      'yearsOfExperience': yearsOfExperience,
    };
  }
}
