part of 'chat_bloc.dart';

sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState{}

final class ChatError extends ChatState{
  final String message;

  ChatError(this.message);
}
 final class ChatLoaded extends ChatState{
  final List<Chat> chats;

  ChatLoaded(this.chats);
 }