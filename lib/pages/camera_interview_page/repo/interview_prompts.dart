import 'dart:convert';

import '../models/interview_question_budget.dart';
import '../models/interview_scorecard_entry.dart';
import '../models/interview_session_details.dart';

String buildQuestionPoolPrompt(InterviewSessionDetails details) {
  return """
You are a professional technical interviewer.

Generate a reusable interview question pool for this session.

Candidate Name: ${details.candidateName}
Interview Topic: ${details.interviewTopic}
Difficulty Level: ${details.difficultyLevel}
Interview Type: ${details.interviewType}
Years of Experience: ${details.yearsOfExperience}

Requirements:
1. Generate exactly 15 questions.
2. Include 5 easy, 5 medium, and 5 hard questions.
3. Questions must be short, clear, TTS-friendly, and suitable for speech answers.
4. Stay strictly within the interview topic, type, difficulty, and experience level.
5. Avoid quotation marks, markdown, bullets, symbols, and multi-part questions inside question text.
6. Each question must include 2 to 4 lowercase topic tags.
7. Return only valid JSON.

JSON shape:
{
  "questions": [
    {
      "id": "q1",
      "question": "Explain ...",
      "difficulty": "easy",
      "tags": ["tag_one", "tag_two"]
    }
  ]
}
""";
}

String buildAdaptiveDecisionPrompt({
  required String answer,
  required String interviewTopic,
  required String interviewType,
  required String yearsOfExperience,
  required String currentDifficulty,
  required List<String> currentQuestionTags,
  required List<String> coveredTags,
  required List<Map<String, dynamic>> unusedPoolPreview,
  required int consecutiveFollowUps,
  required String currentQuestion,
}) {
  return """
You are an adaptive interview decision engine.

Return only valid JSON. Do not return markdown or prose.

Interview context:
Topic: $interviewTopic
Interview Type: $interviewType
Years of Experience: $yearsOfExperience
Current Difficulty: $currentDifficulty
Current Question Tags: ${jsonEncode(currentQuestionTags)}
Covered Tags: ${jsonEncode(coveredTags)}
Unused Pool Preview: ${jsonEncode(unusedPoolPreview)}
Consecutive Follow Ups For Current Question: $consecutiveFollowUps

Current Question:
$currentQuestion

Candidate Answer:
$answer

Decision rules:
1. Use follow_up only when the answer is unclear, incomplete, or worth probing deeper.
2. Use use_pool when the answer is good enough to move forward or the topic is already covered.
3. Never suggest follow_up when consecutive follow ups is 2 or more.
4. The follow_up_question must be short, clear, TTS-friendly, and one sentence.
5. Set difficulty_signal to up for strong answers, down for weak answers, same otherwise.

JSON shape:
{
  "action": "follow_up",
  "answer_quality": "partial",
  "difficulty_signal": "same",
  "follow_up_question": "Can you clarify ...",
  "suggest_wrap_up": false
}
""";
}

String buildFinalEvaluationPrompt({
  required InterviewSessionDetails details,
  required List<InterviewScorecardEntry> scorecard,
  required InterviewQuestionBudget questionBudget,
}) {
  return """
You are a professional technical interviewer.

Generate a complete evaluation report from this compact interview scorecard.
Do not assume any extra answers beyond the scorecard.

Interview details:
Candidate Name: ${details.candidateName}
Interview Topic: ${details.interviewTopic}
Difficulty Level: ${details.difficultyLevel}
Interview Type: ${details.interviewType}
Years of Experience: ${details.yearsOfExperience}
Questions Answered: ${scorecard.length}
Question Budget: ${questionBudget.minQuestions}-${questionBudget.maxQuestions}

Scorecard JSON:
${jsonEncode(scorecard.map((entry) => entry.toJson()).toList(growable: false))}

Report Requirements:
1. Use proper Markdown formatting.
2. Use clear section headings with ## and ###.
3. Use bullet points and numbered lists wherever appropriate.
4. Highlight important terms using bold text.
5. Keep spacing clean and readable.
6. Be lenient with minor speech-to-text transcription errors.
7. Focus more on intent and conceptual correctness than exact wording.
8. Keep feedback constructive and actionable.

Evaluation Sections:

## Candidate Summary

## Strengths

## Weaknesses

## Question-wise Feedback

For each question include:
- Expected concept
- Candidate response summary
- Evaluation as Correct, Partial, or Incorrect
- Improvement tip

## Suggestions for Improvement

## Final Evaluation

Include overall rating as Beginner, Intermediate, or Strong with a short justification and interview readiness status.
""";
}
