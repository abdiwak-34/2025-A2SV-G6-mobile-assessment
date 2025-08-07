part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}
final class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

final class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  SignUpEvent(this.name, this.email, this.password);

  @override
  List<Object> get props => [name, email, password];
}

final class LogoutEvent extends AuthEvent {}