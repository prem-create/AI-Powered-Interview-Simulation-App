class InterviewAdaptiveDecision {
  const InterviewAdaptiveDecision({
    required this.action,
    required this.answerQuality,
    required this.difficultySignal,
    required this.suggestWrapUp,
    this.followUpQuestion,
  });

  final AdaptiveAction action;
  final AnswerQuality answerQuality;
  final DifficultySignal difficultySignal;
  final bool suggestWrapUp;
  final String? followUpQuestion;

  factory InterviewAdaptiveDecision.fromJson(Map<String, dynamic> json) {
    final action = AdaptiveAction.fromValue(json['action']);
    final answerQuality = AnswerQuality.fromValue(json['answer_quality']);
    final difficultySignal = DifficultySignal.fromValue(
      json['difficulty_signal'],
    );
    final followUpQuestion = _optionalString(json['follow_up_question']);

    return InterviewAdaptiveDecision(
      action: action,
      answerQuality: answerQuality,
      difficultySignal: difficultySignal,
      suggestWrapUp: json['suggest_wrap_up'] == true,
      followUpQuestion: followUpQuestion,
    );
  }

  static String? _optionalString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}

enum AdaptiveAction {
  followUp,
  usePool;

  static AdaptiveAction fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'follow_up') return AdaptiveAction.followUp;
    return AdaptiveAction.usePool;
  }
}

enum AnswerQuality {
  correct,
  partial,
  incorrect;

  static AnswerQuality fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'correct') return AnswerQuality.correct;
    if (normalized == 'incorrect') return AnswerQuality.incorrect;
    return AnswerQuality.partial;
  }

  String get value {
    switch (this) {
      case AnswerQuality.correct:
        return 'correct';
      case AnswerQuality.partial:
        return 'partial';
      case AnswerQuality.incorrect:
        return 'incorrect';
    }
  }
}

enum DifficultySignal {
  up,
  same,
  down;

  static DifficultySignal fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'up') return DifficultySignal.up;
    if (normalized == 'down') return DifficultySignal.down;
    return DifficultySignal.same;
  }
}
