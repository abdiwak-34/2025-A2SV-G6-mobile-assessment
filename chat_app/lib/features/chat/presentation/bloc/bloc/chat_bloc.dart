import 'package:bloc/bloc.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/usecases/get_all_chats.dart';
import 'package:chat_app/features/chat/domain/usecases/get_chat_messages.dart';
import 'package:chat_app/features/chat/domain/usecases/initiate_chat.dart';
import 'package:chat_app/features/chat/domain/usecases/send_message.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetAllChatsUsecase getAllChats;
  final InitiateChatUsecase initiateChat;
  final GetChatMessages getChatMessages;
  final SendMessage sendMessage;

  ChatBloc({required this.getAllChats, required this.initiateChat, required this.getChatMessages, required this.sendMessage}) : super(ChatInitial()) {
    on<GetAllChatsEvent>(_onGetAllChats);
    on<InitiateChatEvent>(_onInitiateChat);
    on<GetChatMessagesEvent>(_onGetChatMessages);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onInitiateChat(
    InitiateChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await initiateChat(event.userId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chat) => emit(ChatInitiated(chat)),
    );
  }

  Future<void> _onGetAllChats(
    GetAllChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await getAllChats(NoParams());
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chats) => emit(ChatLoaded(chats)),
    );
  }

  Future<void> _onGetChatMessages(
    GetChatMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await getChatMessages(event.chatId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(ChatMessagesLoaded(messages)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final params = SendMessageParameters(
      chatId: event.chatId,
      message: event.message,
      type: event.type,
    );
    final result = await sendMessage(params);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) => emit(ChatMessageSended()),
    );
  }
}