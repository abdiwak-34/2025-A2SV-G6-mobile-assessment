import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/auth/domain/entities/signup_entity.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignUpUsecase implements UseCase<User,SignupData>{
  final AuthRepository authRepository;

  SignUpUsecase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(SignupData data) async {
    return await authRepository.signUp(data);
  }
}