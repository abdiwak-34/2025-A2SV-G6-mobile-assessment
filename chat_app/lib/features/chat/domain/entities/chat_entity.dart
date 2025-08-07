import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

class Chat {
  final String id;
  final User user1;
  final User user2;

  const Chat({
    required this.id,
    required this.user1,
    required this.user2,
  });
}