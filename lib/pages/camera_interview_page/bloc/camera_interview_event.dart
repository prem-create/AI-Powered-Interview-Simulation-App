// ============================================================================
// CAMERA INTERVIEW EVENTS - User Actions During Interview
// ============================================================================
// Defines all possible events during the camera interview session
// ============================================================================

part of 'camera_interview_bloc.dart';

@immutable
sealed class CameraInterviewEvent {}

/// Event: Reset to initial state (interview details form)
class CameraInterviewInitialEvent extends CameraInterviewEvent {}

/// Event: User starts the interview with provided details
/// Contains all necessary information to initialize AI interviewer
class StartCameraInterviewButtonTappedEvent extends CameraInterviewEvent {
  final String candidateName; // Candidate's name for personalization
  // Topic/domain for interview (e.g., Flutter, Java)
  final String InterviewTopic;
  // Easy, Medium, Hard - adjusts question complexity
  final String difficultyLevel;
  final String interviewType; // Technical, HR / Behavioural, or System Design
  final String yearsOfExperience; // Candidate experience range

  StartCameraInterviewButtonTappedEvent({
    required this.candidateName,
    required this.InterviewTopic,
    required this.difficultyLevel,
    required this.interviewType,
    required this.yearsOfExperience,
  });
}

/// Event: Candidate submits an answer to current question
/// Can be regular answer or final answer when ending interview
class CandidateAnswerSubmittedEvent extends CameraInterviewEvent {
  final String answer; // Candidate's response to the question
  final bool isEndInterviewButtonTapped; // True if user wants to end interview

  CandidateAnswerSubmittedEvent({
    required this.answer,
    this.isEndInterviewButtonTapped = false, // Default: continue interview
  });
}

/// Event: Candidate recording has stopped and transcription is starting
/// Shows loading immediately while speech-to-text work runs
class CandidateAnswerTranscriptionStartedEvent extends CameraInterviewEvent {}

/// Event: Candidate answer transcription failed before answer submission
class CandidateAnswerTranscriptionFailedEvent extends CameraInterviewEvent {
  final String errorMessage;

  CandidateAnswerTranscriptionFailedEvent({required this.errorMessage});
}

/// Event: Navigate back to interview details form
/// Allows user to restart with different parameters
class AskInterviewDetailsEvent extends CameraInterviewEvent {}

/// Event: Trigger text-to-speech for AI question
/// Makes interview more realistic by speaking questions aloud
class SpeakTtsEvent extends CameraInterviewEvent {
  final String text; // Text to be spoken (AI question)

  SpeakTtsEvent({required this.text});
}

/// Event: App leaves foreground or interview page is closing
/// Stops active media resources that should not continue in background
class CameraInterviewLifecyclePausedEvent extends CameraInterviewEvent {}
