import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/chat_model.dart';
import '../model/message_model.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheMessages(String chatId, List<MessageModel> messages);
  Future<List<MessageModel>> getCachedMessages(String chatId);
  Future<void> deleteCachedMessages(String chatId);
}

class ChatLocalDatasourcesImpl implements ChatLocalDataSource {
  static const _messagesPrefix = 'cached_messages_';

  final SharedPreferences sharedPreferences;

  ChatLocalDatasourcesImpl(this.sharedPreferences);

  @override
  Future<void> cacheMessages(String chatId, List<MessageModel> messages) async {
    await sharedPreferences.setString(
      '$_messagesPrefix$chatId',
      json.encode(messages.map((m) => m.toJson()).toList()),
    );
  }

  @override
  Future<List<MessageModel>> getCachedMessages(String chatId) async {
    final messagesJson = sharedPreferences.getString('$_messagesPrefix$chatId');
    if (messagesJson == null) return [];

    try {
      return (json.decode(messagesJson) as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (_) {
      await deleteCachedMessages(chatId);
      return [];
    }
  }

  @override
  Future<void> deleteCachedMessages(String chatId) async {
    await sharedPreferences.remove('$_messagesPrefix$chatId');
  }


}