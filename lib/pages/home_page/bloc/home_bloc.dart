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
import 'package:interview_app/core/services/remote_config_service.dart';
import 'package:interview_app/pages/auth/repo/auth_repository.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

/// HomeBloc: Manages home page state and navigation logic
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    AuthRepository? authRepository,
    RemoteConfigService? remoteConfigService,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _remoteConfigService = remoteConfigService ?? RemoteConfigService(),
       super(HomeInitial()) {
    // Register event handlers
    on<HomeStarted>(homeStarted);
    on<RetryApiKeysFetchRequested>(retryApiKeysFetchRequested);
    on<CameraInterviewButtonClicked>(cameraInterviewButtonClicked);
    on<StartTalkToAiButtonClicked>(startTalkToAiButtonClicked);
    on<LogoutButtonClicked>(logoutButtonClicked);
  }

  final AuthRepository _authRepository;
  final RemoteConfigService _remoteConfigService;

  Future<void> homeStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (_remoteConfigService.hasApiKeys) {
      emit(HomeInitial());
      return;
    }

    await _loadApiKeys(emit);
  }

  Future<void> retryApiKeysFetchRequested(
    RetryApiKeysFetchRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadApiKeys(emit);
  }

  /// Handles Camera Interview button click
  /// Emits action state to navigate to camera interview page
  void cameraInterviewButtonClicked(
    CameraInterviewButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    if (!_remoteConfigService.hasApiKeys) {
      emit(
        ApiKeyFailureState(
          message:
              'Internet is off. Please turn it on and try again to load the app configuration.',
        ),
      );
      return;
    }

    emit(CameraInterviewActionState());
  }

  /// Handles Talk to AI button click
  /// Emits action state to navigate to chat-based interview page
  void startTalkToAiButtonClicked(
    StartTalkToAiButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    if (!_remoteConfigService.hasApiKeys) {
      emit(
        ApiKeyFailureState(
          message:
              'Internet is off. Please turn it on and try again to load the app configuration.',
        ),
      );
      return;
    }

    emit(StartTalkToAiActionState());
  }

  Future<void> logoutButtonClicked(
    LogoutButtonClicked event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _authRepository.logout();
      emit(LogoutSuccessActionState());
    } on AuthException catch (error) {
      emit(LogoutFailureActionState(message: error.message));
    } catch (_) {
      emit(
        LogoutFailureActionState(
          message: 'Could not log out. Please try again.',
        ),
      );
    }
  }

  Future<void> _loadApiKeys(Emitter<HomeState> emit) async {
    emit(ApiKeyState());

    try {
      await _remoteConfigService.loadApiKeys();
      emit(HomeInitial());
    } on RemoteConfigLoadException catch (error) {
      emit(ApiKeyFailureState(message: error.message));
    } catch (_) {
      emit(
        ApiKeyFailureState(
          message:
              'Internet is off. Please turn it on and try again to load the app configuration.',
        ),
      );
    }
  }
}
