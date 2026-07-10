import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:interview_app/pages/auth/repo/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(AuthInitial()) {
    on<LoginSubmitted>(_loginSubmitted);
    on<GoogleLoginSubmitted>(_googleLoginSubmitted);
    on<ForgotPasswordSubmitted>(_forgotPasswordSubmitted);
    on<CreateAccountSubmitted>(_createAccountSubmitted);
  }

  final AuthRepository _authRepository;

  FutureOr<void> _loginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.login(email: event.email, password: event.password);

      emit(
        AuthSuccess(
          'Logged in successfully.',
          action: AuthSuccessAction.navigateHome,
        ),
      );
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
    } catch (_) {
      emit(AuthFailure('Could not log in. Please try again.'));
    }
  }

  FutureOr<void> _googleLoginSubmitted(
    GoogleLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.loginWithGoogle();

      emit(
        AuthSuccess(
          'Logged in successfully.',
          action: AuthSuccessAction.navigateHome,
        ),
      );
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
    } catch (_) {
      emit(AuthFailure('Could not log in with Google. Please try again.'));
    }
  }

  FutureOr<void> _forgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.sendPasswordResetEmail(email: event.email);

      emit(
        AuthSuccess(
          'Password reset link sent. Please check your email.',
          action: AuthSuccessAction.showMessageAndLoginAfterPasswordReset,
        ),
      );
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
    } catch (_) {
      emit(
        AuthFailure(
          'Could not send the password reset link. Please try again.',
        ),
      );
    }
  }

  FutureOr<void> _createAccountSubmitted(
    CreateAccountSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.createAccount(
        email: event.email,
        password: event.password,
      );

      emit(
        AuthSuccess(
          'Account created. Please check your email to verify your account.',
          action: AuthSuccessAction.showMessageAndLogin,
        ),
      );
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
    } catch (_) {
      emit(AuthFailure('Could not create your account. Please try again.'));
    }
  }
}
