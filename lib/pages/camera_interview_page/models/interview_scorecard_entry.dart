class InterviewScorecardEntry {
  const InterviewScorecardEntry({
    required this.question,
    required this.answer,
    required this.answerQuality,
    required this.difficulty,
    required this.tags,
    required this.source,
  });

  final String question;
  final String answer;
  final String answerQuality;
  final String difficulty;
  final List<String> tags;
  final String source;

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'answer_quality': answerQuality,
      'difficulty': difficulty,
      'tags': tags,
      'source': source,
    };
  }
}
