part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class LoginSubmitted extends AuthEvent {
  LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}

final class GoogleLoginSubmitted extends AuthEvent {}

final class ForgotPasswordSubmitted extends AuthEvent {
  ForgotPasswordSubmitted({required this.email});

  final String email;
}

final class CreateAccountSubmitted extends AuthEvent {
  CreateAccountSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}
