import 'package:chat_app/dependency_injection.dart' as di;
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/usecases/initiate_chat.dart';
import 'package:chat_app/features/chat/presentation/bloc/bloc/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ChatBloc>().add(const GetAllChatsEvent('current_user_id'));
    context.read<AuthBloc>().add(GetUsersEvent());

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// Blue background taking top 1/4 of the screen
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              color: Colors.blue,
            ),

            /// Main content
            Column(
              children: [
                const SizedBox(height: 20),

                /// Horizontal user list inside the blue part
                SizedBox(
                  height: 100,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      } else if (state is UsersLoaded) {
                        final users = state.users;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return _buildUserStory(users[index]);
                          },
                        );
                      } else if (state is AuthError) {
                        return Center(
                          child: Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// Chat list container (white, rounded top, overlapping blue background)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.blue),
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
                            return const Center(child: Text('No chats yet'));
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<ChatBloc>()
                                  .add(const GetAllChatsEvent('current_user_id'));
                            },
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                return _buildChatTile(context, chats[index]);
                              },
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartChatSheet(context),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('New Chat'),
      ),
    );
  }

  static Widget _buildUserStory(User user) {
    String initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueAccent,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              user.name,
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

  Widget _buildChatTile(BuildContext context, Chat chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            chat.user2.name.isNotEmpty
                ? chat.user2.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        title: Text(chat.user2.name),
        subtitle: Text(chat.user2.email),
        trailing: const Icon(Icons.chevron_right),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Start new chat', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final targetId = controller.text.trim();
                  if (targetId.isEmpty) return;
                  Navigator.of(ctx).pop();
                  final res = await di.sl<InitiateChat>()(targetId);
                  res.fold(
                    (failure) {},
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
            ],
          ),
        );
      },
    );
  }
}
