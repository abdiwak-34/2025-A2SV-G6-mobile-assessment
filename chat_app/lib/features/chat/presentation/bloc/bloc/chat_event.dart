part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class InitiateChatEvent extends ChatEvent {
  final String userId;

  const InitiateChatEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetAllChatsEvent extends ChatEvent {
  const GetAllChatsEvent();

  @override
  List<Object> get props => [];
}

class GetChatMessagesEvent extends ChatEvent {
  final String chatId;

  const GetChatMessagesEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String message;
  final String type;

  const SendMessageEvent(this.chatId, this.message, this.type);

  @override
  List<Object> get props => [chatId, message, type];
}