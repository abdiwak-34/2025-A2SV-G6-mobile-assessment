import 'dart:developer';

import 'package:chat_app/features/auth/data/datasources/local_data_sources.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  final AuthLocalDataSource authLocalDataSource;
  IO.Socket? _socket;

  static const String _baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com';

  SocketService(this.authLocalDataSource);

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await authLocalDataSource.getCachedAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token for socket connection');
    }

    final opts = IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .disableAutoConnect() // connect manually
        .build();

    _socket = IO.io(_baseUrl, opts);

    _socket!.onConnect((_) => log('Socket connected'));
    _socket!.onDisconnect((_) => log('Socket disconnected'));
    _socket!.onError((e) => log('Socket error: $e'));

    _socket!.connect();
  }

  bool get isConnected => _socket?.connected ?? false;

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
