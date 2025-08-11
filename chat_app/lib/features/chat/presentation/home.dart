import 'package:chat_app/features/chat/presentation/bloc/bloc/chat_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/presentation/chat_detail_page.dart';
import 'package:chat_app/features/chat/domain/usecases/initiate_chat.dart';
import 'package:chat_app/dependency_injection.dart' as di;

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ChatBloc>().add(const GetAllChatsEvent('current_user_id'));

    return Stack(
      children: [
        // Blue background
        Container(color: Colors.blue),

        // Scaffold with transparent background
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30), // ~3cm from top
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12),
                  child: SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dummyStories.length,
                      itemBuilder: (context, index) {
                        final story = dummyStories[index];
                        return _buildStory(
                            story["name"]!, story["image"]!);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 30,),

                // White container for body
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [

                        // Chat List
                        Expanded(
                          child: BlocBuilder<ChatBloc, ChatState>(
                            builder: (context, state) {
                              if (state is ChatLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                );
                              } else if (state is ChatError) {
                                return Center(
                                  child: Text(
                                    'Failed to load chats\n${state.message}',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              } else if (state is ChatLoaded) {
                                final chats = state.chats;
                                if (chats.isEmpty) {
                                  return const Center(
                                      child: Text('No chats yet'));
                                }
                                return RefreshIndicator(
                                  onRefresh: () async {
                                    context.read<ChatBloc>().add(
                                        const GetAllChatsEvent(
                                            'current_user_id'));
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: chats.length,
                                    itemBuilder: (context, index) {
                                      final chat = chats[index];
                                      return _buildChatTile(context, chat);
                                    },
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showStartChatSheet(context),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('New Chat'),
          ),
        ),
      ],
    );
  }

  // Dummy stories data
  static final List<Map<String, String>> dummyStories = [
    {"name": "My status", "image": "https://i.pravatar.cc/150?img=1"},
    {"name": "Adil", "image": "https://i.pravatar.cc/150?img=2"},
    {"name": "Marina", "image": "https://i.pravatar.cc/150?img=3"},
    {"name": "Dean", "image": "https://i.pravatar.cc/150?img=4"},
    {"name": "Max", "image": "https://i.pravatar.cc/150?img=5"},
  ];

  // Build story avatar with gradient border
  static Widget _buildStory(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Build chat tile with blue background
  Widget _buildChatTile(BuildContext context, Chat chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue[100],
          child: Text(
            chat.user2.name.isNotEmpty
                ? chat.user2.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        title: Text(
          chat.user2.name.isNotEmpty ? chat.user2.name : 'Unknown User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          chat.user2.email,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailPage(chat: chat),
            ),
          );
        },
      ),
    );
  }

  void _showStartChatSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start new chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final targetId = controller.text.trim();
                    if (targetId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a user id')),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop();
                    final res = await di.sl<InitiateChat>()(targetId);
                    res.fold(
                      (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to create chat')),
                        );
                      },
                      (chat) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailPage(chat: chat),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Start'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
