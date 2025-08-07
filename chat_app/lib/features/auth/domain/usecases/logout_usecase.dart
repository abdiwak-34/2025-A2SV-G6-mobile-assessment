import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/auth/domain/entities/login_entity.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUsecase implements UseCase<Unit, NoParams>{
  final AuthRepository authRepository;

  LogoutUsecase(this.authRepository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await authRepository.logout();
  }
}