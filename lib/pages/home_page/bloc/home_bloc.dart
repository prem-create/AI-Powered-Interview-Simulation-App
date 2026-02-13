// ============================================================================
// HOME BLOC - Business Logic for Home Page
// ============================================================================
// Manages state and events for the home page navigation
// 
// RESPONSIBILITIES:
// 1. Handle button clicks for different interview modes
// 2. Validate API key before allowing access to AI features
// 3. Emit navigation states to trigger route changes
// 
// EVENT FLOW:
// User clicks button → Event dispatched → BLoC processes → State emitted → UI reacts
// ============================================================================

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

/// HomeBloc: Manages home page state and navigation logic
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    // Register event handlers
    on<CameraInterviewButtonClicked>(cameraInterviewButtonClicked);
    on<StartTalkToAiButtonClicked>(startTalkToAiButtonClicked);
    on<StartMcqButtonClicked>(startMcqButtonClicked);
    on<ApiKeyEvent>(apiKeyEvent);
    on<ApiKeyRecievedEvent>(apiKeyRecievedEvent);
  }

  /// Handles Camera Interview button click
  /// Emits action state to navigate to camera interview page
  FutureOr<void> cameraInterviewButtonClicked(
    CameraInterviewButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    emit(CameraInterviewActionState());
  }

  /// Handles Talk to AI button click
  /// Emits action state to navigate to chat-based interview page
  FutureOr<void> startTalkToAiButtonClicked(
    StartTalkToAiButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    emit(StartTalkToAiActionState());
  }

  /// Validates API key on app startup
  /// Ensures Gemini API is configured before user can access AI features
  /// TODO: Add actual API key validation logic with error handling
  FutureOr<void> apiKeyEvent(ApiKeyEvent event, Emitter<HomeState> emit) {
    emit(ApiKeyState());
  }

  /// Handles successful API key validation
  /// Returns to initial home state after validation
  FutureOr<void> apiKeyRecievedEvent(
    ApiKeyRecievedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeInitial());
  }

  /// Handles MCQ Quiz button click
  /// Emits action state to navigate to quiz screen
  FutureOr<void> startMcqButtonClicked(
    StartMcqButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    emit(McqActionState());
  }
}
