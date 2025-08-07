import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import '../repositories/chat_repo.dart';

class GetAllChatsUsecase implements UseCase<List<Chat>, NoParams> {
  final ChatRepository repository;

  GetAllChatsUsecase(this.repository);

  Future<Either<Failure, List<Chat>>> call(NoParams params) async {
    return await repository.getChats();
  }
}