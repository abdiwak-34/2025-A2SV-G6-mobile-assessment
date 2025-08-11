import 'package:dartz/dartz.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {

  Future<Either<Failure, List<Chat>>> getChats();
  Future<Either<Failure, List<Message>>> getChatMessages(String chatId);
  Future<Either<Failure, Chat>> getChatById(String chatId);
  Future<Either<Failure, Chat>> initiateChat(String userId);
  Future<Either<Failure, Unit>> deleteChat(String chatId);
  Future<Either<Failure, Unit>> sendMessage(String chatId, String message, String type);

}