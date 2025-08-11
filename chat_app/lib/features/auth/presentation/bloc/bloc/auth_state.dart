part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String token;
  final User user;

  const Authenticated(this.token, this.user);

  @override
  List<Object> get props => [token, user];
}

final class UnAuthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

final class RegisterSuccess extends AuthState {
  final User user;

  const RegisterSuccess(this.user);

  @override
  List<Object> get props => [user];
}

final class UsersLoaded extends AuthState {
  final List<User> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}