import 'package:chat_app/core/error/exeception.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/network_info.dart';
import 'package:chat_app/core/socket/socket_service.dart';
import 'package:chat_app/features/chat/data/datasources/chat_local_datasources.dart';
import 'package:chat_app/features/chat/data/datasources/chat_remote_datasources.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart';

class ChatRepoImpl implements ChatRepository{
  final ChatLocalDataSource localDataSource;
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SocketService socketService;


  ChatRepoImpl(this.localDataSource, this.remoteDataSource, this.networkInfo, this.socketService);

  @override
  Future<Either<Failure, List<Chat>>> getChats() async {
    try{
      try{
        return right(await remoteDataSource.getChats());
      } on AuthException {
        return left(AuthFailure('authentication failure'));
      } on NotFoundException {
        return left(NotFoundFailure('Not found'));
      } on ServerExceptions {
        return left(ServerFailure('server failure'));
      }
    }on NetworkException{
      return left(NetworkFailure('connection failed'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getChatMessages(String chatId) async{
    try{
      if(await networkInfo.isConnected){
        final response = await remoteDataSource.getChatMessages(chatId);
        localDataSource.cacheMessages(chatId, response);
        return right(response);

      }else{
        return left(NetworkFailure('connection failed'));
      }
    } on AuthException {
      return left(AuthFailure('authentication failure'));
    } on NotFoundException {
      return left(NotFoundFailure('Not found'));
    } on ServerExceptions {
      return left(ServerFailure('server failure'));
    }
  }

  @override
  Future<Either<Failure, Chat>> getChatById(String chatId) async {
    try{
      if(await networkInfo.isConnected){
        final response = await remoteDataSource.getChatById(chatId);
        return right(response);

      }else{
        return left(NetworkFailure('connection failed'));
      }
    } on AuthException {
      return left(AuthFailure('authentication failure'));
    } on NotFoundException {
      return left(NotFoundFailure('Not found'));
    } on ServerExceptions {
      return left(ServerFailure('server failure'));
    }
  }

  @override
  Future<Either<Failure, Chat>> initiateChat(String userId) async{

    try{
      if(await networkInfo.isConnected){
        return right(await remoteDataSource.initiateChat(userId));

      }else{
        return left(NetworkFailure('connection failed'));
      }
    } on AuthException {
      return left(AuthFailure('authentication failure'));
    } on NotFoundException {
      return left(NotFoundFailure('Not found'));
    } on ServerExceptions {
      return left(ServerFailure('server failure'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChat(String chatId) async {
    try{
      if(await networkInfo.isConnected){
        await remoteDataSource.deleteChat(chatId);
        return right(unit);

      }else{
        return left(NetworkFailure('connection failed'));
      }
    } on AuthException {
      return left(AuthFailure('authentication failure'));
    } on NotFoundException {
      return left(NotFoundFailure('Not found'));
    } on ServerExceptions {
      return left(ServerFailure('server failure'));
    }
  }
  

  Future<Either<Failure, Unit>> sendMessage(
    String chatId, String message, String type) async {
    try {
      if (!await networkInfo.isConnected) {
        return left(NetworkFailure('connection failed'));
      }

      if (!socketService.isConnected) {
        await socketService.connect();
      }

      socketService.emit('message:send', {
        'chatId': chatId,
        'content': message,
        'type': type,
      });

      return right(unit);
    } on AuthException {
      return left(AuthFailure('authentication failure'));
    } on NotFoundException {
      return left(NotFoundFailure('Not found'));
    } on ServerExceptions {
      return left(ServerFailure('server failure'));
    }
  }
}