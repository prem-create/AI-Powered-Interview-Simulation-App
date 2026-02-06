part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class CameraInterviewButtonClicked extends HomeEvent {}

final class StartTalkToAiButtonClicked extends HomeEvent {}

final class StartMcqButtonClicked extends HomeEvent {}

final class ApiKeyEvent extends HomeEvent {}

final class ApiKeyRecievedEvent extends HomeEvent {}
