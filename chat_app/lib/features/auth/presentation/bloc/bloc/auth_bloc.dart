import 'package:bloc/bloc.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/auth/domain/entities/login_entity.dart';
import 'package:chat_app/features/auth/domain/entities/signup_entity.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase login;
  final SignUpUsecase signUp;
  final LogoutUsecase logout;
  final GetcurrentUserUsecase getCurrentUser;

  AuthBloc({
    required this.login,
    required this.signUp,
    required this.logout,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final loginResult = await login(LoginData(
      email: event.email,
      password: event.password,
    ));

    await loginResult.fold(
      (failure) async {
        emit(AuthError(failure.toString()));
      },
      (token) async {
        final userResult = await getCurrentUser(token);
        userResult.fold(
          (failure) => emit(AuthError(failure.toString())),
          (user) async {
            emit(Authenticated(token, user));
          },
        );
      },
    );
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUp(SignupData(
      name: event.name,
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(RegisterSuccess(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logout(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (_) => emit(UnAuthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    // Check if user has cached token and user data
    try {
      // This would typically check local storage for cached auth data
      // For now, we'll emit UnAuthenticated to force fresh login
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError('Failed to check authentication status'));
    }
  }
}