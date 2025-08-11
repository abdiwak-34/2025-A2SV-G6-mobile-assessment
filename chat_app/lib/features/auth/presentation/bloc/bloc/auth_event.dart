part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

final class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignUpEvent(this.name, this.email, this.password);

  @override
  List<Object> get props => [name, email, password];
}

final class LogoutEvent extends AuthEvent {}

final class GetUsersEvent extends AuthEvent {
  const GetUsersEvent();

  @override
  List<Object> get props => [];
}

final class CheckAuthStatusEvent extends AuthEvent {}