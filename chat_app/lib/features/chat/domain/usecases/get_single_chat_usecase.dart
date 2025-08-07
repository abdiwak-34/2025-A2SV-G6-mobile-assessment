import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import '../repositories/chat_repo.dart';

class GetChatByIdUsecase implements UseCase<Chat, String>{
  final ChatRepository repository;

  GetChatByIdUsecase(this.repository);

  Future<Either<Failure, Chat>> call(String chatId) async {
    
    if (chatId.isEmpty) {
      return Left(InvalidInputFailure('invalid input'));
    }

    return await repository.getChatById(chatId);
  }
}