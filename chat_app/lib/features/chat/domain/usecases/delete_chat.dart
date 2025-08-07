import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:chat_app/core/error/failures.dart';
import '../repositories/chat_repo.dart';

class DeleteChatUsecase implements UseCase<Unit, String> {
  final ChatRepository repository;

  DeleteChatUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.deleteChat(userId);
  }
}