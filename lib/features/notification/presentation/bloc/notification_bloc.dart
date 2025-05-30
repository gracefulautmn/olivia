import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/notification/domain/entities/notification.dart';
import 'package:olivia/features/notification/domain/usecases/get_notifications.dart';
import 'package:olivia/features/notification/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:olivia/features/notification/domain/usecases/mark_notification_as_read.dart';
// Untuk stream notif baru dan unread count:
import 'package:olivia/features/notification/domain/repositories/notification_repository.dart'; // Repository langsung untuk stream
import 'package:olivia/features/notification/domain/usecases/get_unread_notification_count.dart'; // Untuk stream unread count

part 'notification_event.dart';
part 'notification_state.dart';

const _notificationLimit = 15;

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications _getNotificationsUseCase;
  final MarkNotificationAsRead _markNotificationAsReadUseCase;
  final MarkAllNotificationsAsRead _markAllNotificationsAsReadUseCase;
  // final GetUnreadNotificationCount _getUnreadNotificationCountUseCase; // Bisa dipakai untuk initial count

  // Untuk stream, bisa pakai repository langsung atau buat usecase stream
  final NotificationRepository _notificationRepository;
  StreamSubscription<Either<Failure, NotificationEntity>>?
  _newNotificationSubscription;
  StreamSubscription<Either<Failure, int>>? _unreadCountSubscription;
  String? _currentUserIdForStreams;

  NotificationBloc({
    required GetNotifications getNotificationsUseCase,
    required MarkNotificationAsRead markNotificationAsReadUseCase,
    required MarkAllNotificationsAsRead markAllNotificationsAsReadUseCase,
    required NotificationRepository notificationRepository, // Inject repository
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
       _markAllNotificationsAsReadUseCase = markAllNotificationsAsReadUseCase,
       _notificationRepository = notificationRepository,
       super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkSingleNotificationRead>(_onMarkSingleNotificationRead);
    on<MarkAllUserNotificationsRead>(_onMarkAllUserNotificationsRead);
    on<_NewNotificationReceived>(_onNewNotificationReceived);
    on<_UnreadCountUpdated>(_onUnreadCountUpdated);
  }

  void _initializeStreams(String userId) {
    if (_currentUserIdForStreams == userId &&
        (_newNotificationSubscription != null ||
            _unreadCountSubscription != null)) {
      // Streams sudah diinisialisasi untuk user ini
      return;
    }
    _currentUserIdForStreams = userId;

    _newNotificationSubscription?.cancel();
    _newNotificationSubscription = _notificationRepository
        .getNewNotificationStream(userId) // Stream dari repository
        .listen((eitherResult) {
          eitherResult.fold(
            (failure) => print(
              "Error from new notification stream: ${failure.message}",
            ), // Log error
            (newNotification) => add(_NewNotificationReceived(newNotification)),
          );
        });

    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = GetUnreadNotificationCountStream(
      _notificationRepository,
    ) // Use case stream
    .call(GetUnreadNotificationCountParams(userId: userId)).listen((
      eitherResult,
    ) {
      eitherResult.fold(
        (failure) => print(
          "Error from unread count stream: ${failure.message}",
        ), // Log error
        (count) => add(_UnreadCountUpdated(count)),
      );
    });
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          status: NotificationStatus.loading,
          notifications: [],
          hasReachedMax: false,
          clearFailure: true,
        ),
      );
    } else {
      emit(
        state.copyWith(status: NotificationStatus.loading, clearFailure: true),
      );
    }
    _initializeStreams(event.userId); // Pastikan stream diinisialisasi/diupdate

    final result = await _getNotificationsUseCase(
      GetNotificationsParams(
        userId: event.userId,
        limit: _notificationLimit,
        offset: 0,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: NotificationStatus.failure, failure: failure),
      ),
      (notifications) {
        emit(
          state.copyWith(
            status: NotificationStatus.loaded,
            notifications: notifications,
            hasReachedMax: notifications.length < _notificationLimit,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.hasReachedMax || state.status == NotificationStatus.loadingMore)
      return;

    emit(state.copyWith(status: NotificationStatus.loadingMore));
    final currentOffset = state.notifications.length;
    final result = await _getNotificationsUseCase(
      GetNotificationsParams(
        userId: event.userId,
        limit: _notificationLimit,
        offset: currentOffset,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: NotificationStatus.failure, failure: failure),
      ), // Atau tetap loaded dengan error
      (newNotifications) {
        if (newNotifications.isEmpty) {
          emit(
            state.copyWith(
              status: NotificationStatus.allLoaded,
              hasReachedMax: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: NotificationStatus.loaded,
              notifications: List.of(state.notifications)
                ..addAll(newNotifications),
              hasReachedMax: newNotifications.length < _notificationLimit,
            ),
          );
        }
      },
    );
  }

  Future<void> _onMarkSingleNotificationRead(
    MarkSingleNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _markNotificationAsReadUseCase(
      MarkNotificationAsReadParams(notificationId: event.notificationId),
    );
    result.fold(
      (failure) {
        /* Log error, mungkin tampilkan snackbar */
      },
      (_) {
        // Update list notifikasi di state
        final updatedNotifications =
            state.notifications.map((notif) {
              if (notif.id == event.notificationId) {
                return NotificationEntity(
                  // Buat instance baru dengan isRead = true
                  id: notif.id,
                  recipientId: notif.recipientId,
                  title: notif.title,
                  body: notif.body,
                  type: notif.type,
                  relatedItemId: notif.relatedItemId,
                  relatedChatId: notif.relatedChatId,
                  isRead: true,
                  createdAt: notif.createdAt,
                );
              }
              return notif;
            }).toList();
        emit(
          state.copyWith(
            notifications: updatedNotifications,
            unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          ),
        );
      },
    );
  }

  Future<void> _onMarkAllUserNotificationsRead(
    MarkAllUserNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _markAllNotificationsAsReadUseCase(
      MarkAllNotificationsAsReadParams(userId: event.userId),
    );
    result.fold(
      (failure) {
        /* Log error */
      },
      (_) {
        final updatedNotifications =
            state.notifications.map((notif) {
              return NotificationEntity(
                id: notif.id,
                recipientId: notif.recipientId,
                title: notif.title,
                body: notif.body,
                type: notif.type,
                relatedItemId: notif.relatedItemId,
                relatedChatId: notif.relatedChatId,
                isRead: true,
                createdAt: notif.createdAt,
              );
            }).toList();
        emit(
          state.copyWith(notifications: updatedNotifications, unreadCount: 0),
        );
      },
    );
  }

  void _onNewNotificationReceived(
    _NewNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    // Tambahkan notifikasi baru ke awal list dan update unread count
    // Hindari duplikasi jika notifikasi sudah ada (berdasarkan ID)
    if (!state.notifications.any((n) => n.id == event.newNotification.id)) {
      final newList = [event.newNotification, ...state.notifications];
      // Potong list jika terlalu panjang setelah menambah (opsional)
      // if (newList.length > _notificationLimit * 2) { // Misal batas maksimal 2x page limit
      //   newList.removeRange(_notificationLimit * 2, newList.length);
      // }
      emit(
        state.copyWith(
          notifications: newList,
          // unreadCount: state.unreadCount + (event.newNotification.isRead ? 0 : 1) // Unread count akan dihandle _UnreadCountUpdated
        ),
      );
    }
  }

  void _onUnreadCountUpdated(
    _UnreadCountUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(unreadCount: event.unreadCount));
  }

  @override
  Future<void> close() {
    _newNotificationSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
