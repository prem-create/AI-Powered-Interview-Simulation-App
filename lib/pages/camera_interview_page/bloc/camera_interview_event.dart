part of 'camera_interview_bloc.dart';

@immutable
sealed class CameraInterviewEvent {}

class CameraInterviewInitialEvent extends CameraInterviewEvent {}

class StartCameraInterviewButtonTappedEvent extends CameraInterviewEvent {
  final String candidateName;
  final String InterviewTopic;
  final String difficultyLevel;

  StartCameraInterviewButtonTappedEvent({
    required this.candidateName,
    required this.InterviewTopic,
    required this.difficultyLevel,
  });
}

class CandidateAnswerSubmittedEvent extends CameraInterviewEvent {
  final String answer;

  CandidateAnswerSubmittedEvent({required this.answer});
}

class AskInterviewDetailsEvent extends CameraInterviewEvent {}

class SpeakTtsEvent extends CameraInterviewEvent {
  final String text;

  SpeakTtsEvent({required this.text});
}