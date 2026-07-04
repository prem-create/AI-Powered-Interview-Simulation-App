class InterviewTurnResponse {
  const InterviewTurnResponse._({
    this.question,
    required this.shouldGenerateResult,
    required this.canSuggestWrapUp,
  });

  final String? question;
  final bool shouldGenerateResult;
  final bool canSuggestWrapUp;

  const InterviewTurnResponse.question(
    String question, {
    bool canSuggestWrapUp = false,
  }) : this._(
         question: question,
         shouldGenerateResult: false,
         canSuggestWrapUp: canSuggestWrapUp,
       );

  const InterviewTurnResponse.generateResult()
    : this._(shouldGenerateResult: true, canSuggestWrapUp: false);
}
