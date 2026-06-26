part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

enum AuthSuccessAction { navigateHome, showMessageAndLogin }

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  AuthSuccess(this.message, {required this.action});

  final String message;
  final AuthSuccessAction action;
}

final class AuthFailure extends AuthState {
  AuthFailure(this.message);

  final String message;
}
