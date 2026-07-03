class InterviewQuestionPool {
  const InterviewQuestionPool({required this.questions});

  final List<InterviewPoolQuestion> questions;

  factory InterviewQuestionPool.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    if (rawQuestions is! List) {
      throw const FormatException('Question pool must contain questions list.');
    }

    final questions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map(InterviewPoolQuestion.fromJson)
        .where((question) => question.question.trim().isNotEmpty)
        .toList(growable: false);

    if (questions.isEmpty) {
      throw const FormatException('Question pool cannot be empty.');
    }

    return InterviewQuestionPool(questions: questions);
  }
}

class InterviewPoolQuestion {
  const InterviewPoolQuestion({
    required this.id,
    required this.question,
    required this.difficulty,
    required this.tags,
  });

  final String id;
  final String question;
  final String difficulty;
  final List<String> tags;

  factory InterviewPoolQuestion.fromJson(Map<String, dynamic> json) {
    final question = json['question'];
    final difficulty = json['difficulty'];
    final tags = json['tags'];

    if (question is! String || difficulty is! String || tags is! List) {
      throw const FormatException('Question pool item is invalid.');
    }

    return InterviewPoolQuestion(
      id: _stringValue(json['id']).isEmpty
          ? question.trim()
          : _stringValue(json['id']),
      question: question.trim(),
      difficulty: difficulty.trim().toLowerCase(),
      tags: tags
          .whereType<String>()
          .map((tag) => tag.trim().toLowerCase())
          .where((tag) => tag.isNotEmpty)
          .toList(growable: false),
    );
  }

  static String _stringValue(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}
