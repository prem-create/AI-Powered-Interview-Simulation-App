part of 'camera_interview_bloc.dart';

@immutable
sealed class CameraInterviewState {}

abstract class CameraInterviewActionState extends CameraInterviewState {}

final class CameraInterviewInitial extends CameraInterviewState {}

final class StartCameraInterviewButtonTappedSuccessState
    extends CameraInterviewState {}

final class CameraInterviewLoadingState extends CameraInterviewState {}

final class CameraInterviewLoadingErrorState extends CameraInterviewState {}

final class CameraInterviewLoadingSuccessState extends CameraInterviewState {
  final String question;

  CameraInterviewLoadingSuccessState({required this.question});
}

final class AskInterviewDetailsState extends CameraInterviewActionState {}

final class CameraInterviewResultState extends CameraInterviewState {
  final String result;

  CameraInterviewResultState({required this.result});
}