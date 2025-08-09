import 'package:dartz/dartz.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repo.dart';

class GetChatMessages implements UseCase<List<Message>, String> {
  final ChatRepository repository;

  GetChatMessages(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(String chatId) async {
    return await repository.getChatMessages(chatId);
  }
}