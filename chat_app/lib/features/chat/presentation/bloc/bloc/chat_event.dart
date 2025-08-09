part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class GetAllChatsEvent extends ChatEvent {
  final String currentUserId;

  const GetAllChatsEvent(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}