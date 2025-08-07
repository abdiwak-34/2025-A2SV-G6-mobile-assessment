import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';

class Message {
  final String id;
  final User sender;
  final Chat chat;
  final String type;
  final String content;

  const Message({
    required this.id,
    required this.sender,
    required this.chat,
    required this.type,
    required this.content,
  });
}