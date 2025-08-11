import 'package:dartz/dartz.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class GetUserUsecase implements UseCase<List<User>, NoParams> {
  final AuthRepository authRepository;

  GetUserUsecase(this.authRepository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params) async {
    return await authRepository.getUsers();
  }
}
