import 'package:dartz/dartz.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repo.dart';

class SendMessage implements UseCase<Unit, SendMessageParameters> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendMessageParameters params) async {
    return await repository.sendMessage(
      params.chatId,
      params.message,
      params.type,
    );
  }
}

class SendMessageParameters {
  final String chatId;
  final String message;
  final String type;

  SendMessageParameters({
    required this.chatId,
    required this.message,
    required this.type,
  });
} 