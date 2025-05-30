import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/empty_data_widget.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/features/chat/presentation/widgets/chat_list_item_widget.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  static const String routeName = '/chat-list'; // Atau '/chats' sesuai AppRouter

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Obrolan')),
        body: const Center(child: Text('Anda harus login untuk melihat obrolan.')),
      );
    }

    return BlocProvider(
      create: (context) => sl<ChatListBloc>()..add(LoadChatRooms(authState.user!.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Obrolan'),
          // Tidak ada tombol back jika ini halaman utama di Floating Action Button
          // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state.status == ChatListStatus.loading && state.chatRooms.isEmpty) {
              return const Center(child: LoadingIndicator(message: 'Memuat obrolan...'));
            }
            if (state.status == ChatListStatus.failure && state.chatRooms.isEmpty) {
              return Center(
                child: ErrorDisplayWidget(
                  message: state.failure?.message ?? 'Gagal memuat daftar obrolan.',
                  onRetry: () => context.read<ChatListBloc>().add(LoadChatRooms(authState.user!.id)),
                ),
              );
            }
            if (state.chatRooms.isEmpty) {
              return const Center(
                child: EmptyDataWidget(
                  message: 'Belum ada obrolan.\nAnda bisa memulai obrolan dari detail barang.',
                  icon: Icons.chat_bubble_outline,
                ),
              );
            }

            // Tampilkan daftar chat meskipun status loading (untuk update dari stream)
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatListBloc>().add(LoadChatRooms(authState.user!.id));
              },
              child: ListView.separated(
                itemCount: state.chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = state.chatRooms[index];
                  return ChatListItemWidget(
                    chatRoom: chatRoom,
                    onTap: () {
                      context.pushNamed(
                        ChatDetailPage.routeName,
                        pathParameters: {'chatRoomId': chatRoom.id},
                        queryParameters: {
                          // otherParticipantId dan recipientName sudah ada di ChatRoomEntity
                          'recipientId': chatRoom.otherParticipantId,
                          'recipientName': chatRoom.otherParticipantName ?? 'Chat',
                          'itemId': chatRoom.itemId,
                        }
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
              ),
            );
          },
        ),
      ),
    );
  }
}