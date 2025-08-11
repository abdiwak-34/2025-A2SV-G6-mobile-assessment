import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';

class ChatModel extends Chat {
  const ChatModel({
    required String id,
    required User user1,
    required User user2,
  }) : super(id: id, user1: user1, user2: user2);

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'];
    if (json.containsKey('user1') && json.containsKey('user2')) {
      return ChatModel(
        id: id,
        user1: UserModel.fromJson(json['user1']),
        user2: UserModel.fromJson(json['user2']),
      );
    }
    // Some APIs return participants: [user1, user2]
    if (json.containsKey('participants') && json['participants'] is List) {
      final parts = (json['participants'] as List);
      // Expecting two populated user objects
      final user1Json = parts.isNotEmpty ? parts[0] as Map<String, dynamic> : <String, dynamic>{};
      final user2Json = parts.length > 1 ? parts[1] as Map<String, dynamic> : <String, dynamic>{};
      return ChatModel(
        id: id,
        user1: UserModel.fromJson(user1Json),
        user2: UserModel.fromJson(user2Json),
      );
    }
    // Fallback (will likely throw if data incomplete)
    return ChatModel(
      id: id,
      user1: UserModel.fromJson(json['user1'] ?? {}),
      user2: UserModel.fromJson(json['user2'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user1': (user1 as UserModel).toJson(),
      'user2': (user2 as UserModel).toJson(),
    };
  }
}