import 'dart:async';

import 'package:chat_app/core/socket/socket_service.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/usecases/get_chat_messages.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/dependency_injection.dart' as di;

class ChatDetailPage extends StatefulWidget {
  final Chat chat;
  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  late final SocketService _socketService;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _socketService = di.sl<SocketService>();
    _init();
  }

  Future<void> _init() async {
    // Load existing messages via REST
    final res = await di.sl<GetChatMessages>()(widget.chat.id);
    res.fold(
      (_) {},
      (msgs) => _messages.addAll(msgs),
    );
    setState(() => _loading = false);

    // Connect socket and subscribe to events
    await _socketService.connect();
    _socketService.on('message:delivered', _onServerMessage);
    _socketService.on('message:received', _onServerMessage);
  }

  void _onServerMessage(dynamic data) {
    try {
      if (data is Map && data['chat'] != null) {
        final chatId = (data['chat'] is Map) ? data['chat']['_id'] : data['chat'];
        if (chatId == widget.chat.id) {
          // Minimal inline parse to MessageEntity substitute
          final msg = _InlineMessage(
            id: data['_id']?.toString() ?? '',
            content: data['content']?.toString() ?? '',
            type: data['type']?.toString() ?? 'text',
            senderName: (data['sender'] is Map) ? (data['sender']['name']?.toString() ?? '') : '',
          );
          setState(() => _messages.add(msg));
        }
      }
    } catch (_) {}
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_socketService.isConnected) return;
    _socketService.emit('message:send', {
      'chatId': widget.chat.id,
      'content': text,
      'type': 'text',
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _socketService.off('message:delivered');
    _socketService.off('message:received');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherName = widget.chat.user2.name.isNotEmpty
        ? widget.chat.user2.name
        : 'Chat';
    return Scaffold(
      appBar: AppBar(
        title: Text(otherName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (m is _InlineMessage && m.senderName.isNotEmpty)
                                Text(
                                  m.senderName,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              Text(m.content),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// A lightweight runtime message for socket-only messages without full models
class _InlineMessage implements Message {
  @override
  final String id;
  @override
  final String content;
  @override
  final String type;

  final String senderName;
  final User? _sender;
  final Chat? _chat;

  _InlineMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.senderName,
    User? sender,
    Chat? chat,
  })  : _sender = sender,
        _chat = chat;

  // Unused members from Message entity interface
  @override
  Chat get chat => _chat ?? (throw UnimplementedError());
  @override
  User get sender => _sender ?? (throw UnimplementedError());
}
