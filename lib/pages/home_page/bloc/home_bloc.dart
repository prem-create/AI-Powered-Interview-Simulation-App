import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<CameraInterviewButtonClicked>(cameraInterviewButtonClicked);
    on<StartTalkToAiButtonClicked>(startTalkToAiButtonClicked);
    on<StartMcqButtonClicked>(startMcqButtonClicked);
    on<ApiKeyEvent>(apiKeyEvent);
    on<ApiKeyRecievedEvent>(apiKeyRecievedEvent);
  }

  FutureOr<void> cameraInterviewButtonClicked(
    CameraInterviewButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    emit(CameraInterviewActionState());
  }

  FutureOr<void> startTalkToAiButtonClicked(
    StartTalkToAiButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    emit(StartTalkToAiActionState());
  }

  FutureOr<void> apiKeyEvent(ApiKeyEvent event, Emitter<HomeState> emit) {
    emit(ApiKeyState());
  }

  FutureOr<void> apiKeyRecievedEvent(
    ApiKeyRecievedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeInitial());
  }

  FutureOr<void> startMcqButtonClicked(
    StartMcqButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    emit(McqActionState());
  }
}
