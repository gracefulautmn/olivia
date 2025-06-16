import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';
import 'package:olivia/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/empty_data_widget.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/features/notification/presentation/widgets/notification_list_item_widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();
  late NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = sl<NotificationBloc>();
    final authState = context.read<AuthBloc>().state;

    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      _notificationBloc.add(LoadNotifications(userId: authState.user!.id));
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final authState = context.read<AuthBloc>().state;
      if (authState.status == AuthStatus.authenticated && authState.user != null) {
         _notificationBloc.add(LoadMoreNotifications(userId: authState.user!.id));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifikasi')),
        body: const Center(child: Text('Anda harus login untuk melihat notifikasi.')),
      );
    }
    
    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifikasi'),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state.notifications.any((n) => !n.isRead)) {
                  return TextButton(
                    onPressed: () {
                       context.read<NotificationBloc>().add(MarkAllUserNotificationsRead(authState.user!.id));
                    },
                    child: const Text('Tandai Semua Dibaca', style: TextStyle(color: Colors.white)),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state.status == NotificationStatus.initial || (state.status == NotificationStatus.loading && state.notifications.isEmpty)) {
              return const Center(child: LoadingIndicator(message: 'Memuat notifikasi...'));
            }
            if (state.status == NotificationStatus.failure && state.notifications.isEmpty) {
              return Center(
                child: ErrorDisplayWidget(
                  message: state.failure?.message ?? 'Gagal memuat notifikasi.',
                  onRetry: () => context.read<NotificationBloc>().add(LoadNotifications(userId: authState.user!.id)),
                ),
              );
            }
            if (state.notifications.isEmpty) {
              return Center(
                child: EmptyDataWidget(
                  message: 'Belum ada notifikasi untuk Anda.',
                  icon: Icons.notifications_none_outlined,
                  onActionPressed: () => context.read<NotificationBloc>().add(LoadNotifications(userId: authState.user!.id, refresh: true)),
                  actionText: "Coba Lagi",
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                 context.read<NotificationBloc>().add(LoadNotifications(userId: authState.user!.id, refresh: true));
              },
              child: ListView.separated(
                controller: _scrollController,
                itemCount: state.hasReachedMax ? state.notifications.length : state.notifications.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return state.status == NotificationStatus.loadingMore
                        ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: LoadingIndicator()))
                        : const SizedBox.shrink();
                  }
                  final notification = state.notifications[index];
                  return NotificationListItemWidget(
                    notification: notification,
                    onTap: () {
                      // Tandai dibaca saat notifikasi diklik
                      if (!notification.isRead) {
                        context.read<NotificationBloc>().add(MarkSingleNotificationRead(notification.id));
                      }
                      
                      // === PERBAIKAN UTAMA DI SINI ===
                      // Navigasi berdasarkan tipe notifikasi
                      if (notification.type == 'item_match' && notification.relatedItemId != null) {
                        context.pushNamed(
                          ItemDetailPage.routeName, 
                          pathParameters: {'itemId': notification.relatedItemId!}
                        );
                      } else if (notification.type == 'new_message' && notification.relatedChatId != null) {
                        // Navigasi langsung ke chat room yang sudah ada menggunakan ID-nya.
                        // ChatDetailPage akan memuat detail room berdasarkan ID ini.
                        context.pushNamed(
                          ChatDetailPage.routeName, 
                          pathParameters: {'chatRoomId': notification.relatedChatId!}
                        );
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
              ),
            );
          },
        ),
      ),
    );
  }
}
