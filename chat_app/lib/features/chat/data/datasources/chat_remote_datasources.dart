import 'package:chat_app/core/error/exeception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_app/features/auth/data/datasources/local_data_sources.dart';

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
  final AuthLocalDataSource authLocalDataSource;
  // Keep base without trailing slash to avoid accidental double slashes
  static const String _baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3';

  ChatRemoteDataSourceImpl(this.client, this.authLocalDataSource);

  Future<Map<String, String>> _authHeaders({bool jsonContent = false}) async {
    final token = await authLocalDataSource.getCachedAccessToken();
    if (token == null || token.isEmpty) throw AuthException();
    return {
      if (jsonContent) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ChatModel>> getChats() async {
    final uri = Uri.parse('$_baseUrl/chats');
    final response = await client.get(uri, headers: await _authHeaders());

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
    final response = await client.get(uri, headers: await _authHeaders());

    return _handleResponse<ChatModel>(
      response,
      parse: (json) => ChatModel.fromJson(json['data']),
    );
  }

  @override
  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId/messages');
    final response = await client.get(uri, headers: await _authHeaders());

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
      headers: await _authHeaders(jsonContent: true),
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
    final response = await client.delete(uri, headers: await _authHeaders());

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

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) throw ServerExceptions();
      final body = jsonDecode(response.body) as Map<String, dynamic>;
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