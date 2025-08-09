import 'package:bloc/bloc.dart';
import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/usecases/get_all_chats.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetAllChatsUsecase getAllChats;

  ChatBloc({required this.getAllChats}) : super(ChatInitial()) {
    on<GetAllChatsEvent>(_onGetAllChats);
  }

  Future<void> _onGetAllChats(
    GetAllChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await getAllChats(NoParams());
    result.fold(
      (failure) => emit(ChatError('failed to fetch chats')),
      (chats) => emit(ChatLoaded(chats)),
    );
  }
}