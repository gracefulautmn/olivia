import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/chat/presentation/bloc/chat_detail/chat_detail_bloc.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/features/chat/presentation/widgets/message_bubble_widget.dart';

class ChatDetailPage extends StatefulWidget {
  final String? chatRoomId; // Bisa null jika ini chat baru (akan dibuat)
  final String recipientId; // User ID lawan bicara
  final String recipientName;
  final String? itemId; // Jika chat terkait item

  const ChatDetailPage({
    super.key,
    this.chatRoomId,
    required this.recipientId,
    required this.recipientName,
    this.itemId,
  });

  static const String routeName =
      '/chat-detail/:chatRoomId'; // :chatRoomId bisa 'new'

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatDetailBloc _chatDetailBloc;

  @override
  void initState() {
    super.initState();
    _chatDetailBloc = sl<ChatDetailBloc>();
    final authState = context.read<AuthBloc>().state;

    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      _chatDetailBloc.add(
        InitializeChatRoom(
          chatRoomId:
              widget.chatRoomId == 'new'
                  ? null
                  : widget.chatRoomId, // Handle 'new'
          currentUserId: authState.user!.id,
          otherUserId: widget.recipientId,
          itemId: widget.itemId,
          recipientName: widget.recipientName,
        ),
      );
    }
    // Listener untuk scroll ke bawah saat pesan baru masuk atau keyboard muncul
    _scrollController.addListener(_scrollToBottomListener);
  }

  void _scrollToBottomListener() {
    // Tidak otomatis scroll jika user sedang scroll ke atas
    // if (_scrollController.position.atEdge) {
    //   if (_scrollController.position.pixels == 0) {
    //     // At top, do nothing or load older messages
    //   } else {
    //     // At bottom, stay scrolled
    //   }
    // }
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollToBottomListener);
    _scrollController.dispose();
    // _chatDetailBloc.close(); // Tidak perlu jika dari sl factory
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _chatDetailBloc.add(SendNewMessage(_messageController.text.trim()));
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return BlocProvider.value(
      value: _chatDetailBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipientName),
          // Tambahkan info item jika ada
          // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body: BlocConsumer<ChatDetailBloc, ChatDetailState>(
          listener: (context, state) {
            if (state.status == ChatDetailStatus.sendMessageFailure &&
                state.failure != null) {
              // ignore: avoid_single_cascade_in_expression_statements
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gagal mengirim pesan: ${state.failure!.message}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.status == ChatDetailStatus.messagesLoaded ||
                state.status == ChatDetailStatus.sendMessageSuccess) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(animate: state.messages.isNotEmpty),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ChatDetailStatus.loadingRoom ||
                state.status == ChatDetailStatus.initial) {
              return const Center(
                child: LoadingIndicator(message: 'Membuka obrolan...'),
              );
            }
            if (state.status == ChatDetailStatus.failure &&
                state.chatRoom == null) {
              return Center(
                child: ErrorDisplayWidget(
                  message: state.failure?.message ?? 'Gagal membuka obrolan.',
                  onRetry: () {
                    if (authState.status == AuthStatus.authenticated &&
                        authState.user != null) {
                      _chatDetailBloc.add(
                        InitializeChatRoom(
                          chatRoomId:
                              widget.chatRoomId == 'new'
                                  ? null
                                  : widget.chatRoomId,
                          currentUserId: authState.user!.id,
                          otherUserId: widget.recipientId,
                          itemId: widget.itemId,
                          recipientName: widget.recipientName,
                        ),
                      );
                    }
                  },
                ),
              );
            }

            // Jika room sudah ada, tapi messages masih loading
            if (state.chatRoom != null &&
                (state.status == ChatDetailStatus.loadingMessages ||
                    state.status == ChatDetailStatus.roomLoaded)) {
              // Tampilkan UI chat dasar, dengan loading indicator untuk pesan
            }

            return Column(
              children: [
                Expanded(
                  child:
                      (state.status == ChatDetailStatus.loadingMessages &&
                              state.messages.isEmpty)
                          ? const Center(
                            child: LoadingIndicator(message: 'Memuat pesan...'),
                          )
                          : state.messages.isEmpty
                          ? const Center(child: Text('Mulai percakapan!'))
                          : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe =
                                  message.senderId == authState.user?.id;
                              return MessageBubbleWidget(
                                message: message.content,
                                isMe: isMe,
                                timestamp: message.sentAt,
                                // Anda bisa tambahkan nama pengirim jika group chat
                              );
                            },
                          ),
                ),
                // Input field
                _buildMessageInputField(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageInputField(BuildContext context, ChatDetailState state) {
    bool canSend =
        state.status != ChatDetailStatus.sendingMessage &&
        state.status != ChatDetailStatus.loadingRoom &&
        state.chatRoom != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        // Agar tidak tertutup oleh system UI (misal gestur home)
        child: Row(
          children: [
            // Tombol attachment (opsional)
            // IconButton(
            //   icon: Icon(Icons.attach_file, color: AppColors.subtleTextColor),
            //   onPressed: canSend ? () { /* Logika attachment */ } : null,
            // ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor, // atau warna lain
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5, // Batasi jumlah baris
                enabled: canSend,
                onSubmitted: (_) {
                  if (canSend) _sendMessage();
                },
              ),
            ),
            const SizedBox(width: 8),
            if (state.status == ChatDetailStatus.sendingMessage)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.send),
                color: AppColors.primaryColor,
                iconSize: 28,
                onPressed: canSend ? _sendMessage : null,
              ),
          ],
        ),
      ),
    );
  }
}
