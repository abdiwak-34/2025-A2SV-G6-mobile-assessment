import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'package:chat_app/features/chat/data/model/chat_model.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';

class MessageModel extends Message {
  const MessageModel({
    required String id,
    required UserModel sender,
    required ChatModel chat,
    required String type,
    required String content,
  }) : super(
          id: id,
          sender: sender,
          chat: chat,
          type: type,
          content: content,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      sender: UserModel.fromJson(json['sender']),
      chat: ChatModel.fromJson(json['chat']),
      type: json['type'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': (sender as UserModel).toJson(),
      'chat': (chat as ChatModel).toJson(),
      'type': type,
      'content': content,
    };
  }
}
