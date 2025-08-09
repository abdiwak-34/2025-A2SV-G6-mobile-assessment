import 'package:dartz/dartz.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class GetcurrentUserUsecase implements UseCase<User, String> {
  final AuthRepository authRepository;

  GetcurrentUserUsecase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(String token) async {
    return await authRepository.getCurrentUser(token);
  }
}
