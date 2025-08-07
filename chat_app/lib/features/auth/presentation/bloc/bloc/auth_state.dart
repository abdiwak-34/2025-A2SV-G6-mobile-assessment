part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState{}
final class Authenticated extends AuthState{
  final User user;
  Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

final class UnAuthenticated extends AuthState{}

final class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
