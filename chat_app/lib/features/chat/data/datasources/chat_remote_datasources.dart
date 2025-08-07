import 'package:chat_app/core/error/exeception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/chat_model.dart';
import '../model/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getChats();
  Future<ChatModel> getChatById(String chatId);
  Future<List<MessageModel>> getChatMessages(String chatId);
  Future<ChatModel> initiateChat(String userId);
  Future<void> deleteChat(String chatId);
}



class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://g5-flutter-learning-path-be.onrender.com/api/v3/';

  ChatRemoteDataSourceImpl(this.client);

  @override
  Future<List<ChatModel>> getChats() async {
    final uri = Uri.parse('$_baseUrl/chats');

    final response = await client.get(uri);

    return _handleResponse<List<ChatModel>>(
      response,
      parse: (json) => (json['data'] as List)
          .map((chatJson) => ChatModel.fromJson(chatJson))
          .toList(),
    );
  }

  @override
  Future<ChatModel> getChatById(String chatId) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId');
    final response = await client.get(uri);

    return _handleResponse<ChatModel>(
      response,
      parse: (json) => ChatModel.fromJson(json['data']),
    );
  }

  @override
  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId/messages');
    final response = await client.get(uri);

    return _handleResponse<List<MessageModel>>(
      response,
      parse: (json) => (json['data'] as List)
          .map((msgJson) => MessageModel.fromJson(msgJson))
          .toList(),
    );
  }

  @override
  Future<ChatModel> initiateChat(String userId) async {
    final uri = Uri.parse('$_baseUrl/chats');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'participants': [userId]}),
    );

    return _handleResponse<ChatModel>(
      response,
      parse: (json) => ChatModel.fromJson(json['data']),
    );
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId');
    final response = await client.delete(uri);

    _handleResponse<void>(
      response,
      parse: (_) => null,
    );
  }

  T _handleResponse<T>(
    http.Response response, {
    required T Function(Map<String, dynamic>) parse,
  }) {
    final statusCode = response.statusCode;
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (statusCode >= 200 && statusCode < 300) {
      return parse(body);
    } else if (statusCode == 401) {
      throw AuthException();
    } else if (statusCode == 404) {
      throw NotFoundException();
    } else {
      throw ServerExceptions();
    }
  }
}