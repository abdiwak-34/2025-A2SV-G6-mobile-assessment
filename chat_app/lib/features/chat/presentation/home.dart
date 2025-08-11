import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/presentation/bloc/bloc/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ChatBloc>().add(const GetAllChatsEvent());
    context.read<AuthBloc>().add(GetUsersEvent());

    return Scaffold(
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatInitiated) {
            // Optionally refresh chats list
            context.read<ChatBloc>().add(const GetAllChatsEvent());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailPage(chat: state.chat),
              ),
            );
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Container(color: Colors.blue ,child:  SafeArea(
        
        child: Stack(
          children: [
            /// Blue background taking top 1/4 of the screen
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
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
                            return _buildUsers(context, users[index]);
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
                                  .add(const GetAllChatsEvent());
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
      ),
    )
    );
  }

  Widget _buildUsers(BuildContext context, User user) {
    String initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Create chat?'),
              content: Text('Do you want to start a chat with ${user.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          if (confirm != true) return;

          // Dispatch event to initiate chat; navigation occurs in BlocListener
          context.read<ChatBloc>().add(InitiateChatEvent(user.id));
        },
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
            chat.user1.name.isNotEmpty
                ? chat.user1.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        title: Text(chat.user1.name),
        subtitle: Text(chat.user1.email),
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
}