part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, loaded, loadingMore, failure, allLoaded }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final Failure? failure;
  final bool hasReachedMax; // Untuk pagination, true jika semua data sudah dimuat
  final int unreadCount;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.failure,
    this.hasReachedMax = false,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    Failure? failure,
    bool? hasReachedMax,
    int? unreadCount,
    bool clearFailure = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      failure: clearFailure ? null : failure ?? this.failure,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [status, notifications, failure, hasReachedMax, unreadCount];
}