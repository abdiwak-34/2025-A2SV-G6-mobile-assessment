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

 class ChatInitiated extends ChatState {
  final Chat chat;

  ChatInitiated(this.chat);
}

class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;

  ChatMessagesLoaded(this.messages);
}

class ChatMessageSended extends ChatState {
  ChatMessageSended();
}