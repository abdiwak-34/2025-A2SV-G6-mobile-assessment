import 'package:dartz/dartz.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repo.dart';

class InitiateChat implements UseCase<Chat, String> {
  final ChatRepository repository;

  InitiateChat(this.repository);

  @override
  Future<Either<Failure, Chat>> call(String userId) async {
    return await repository.initiateChat(userId);
  }
}
