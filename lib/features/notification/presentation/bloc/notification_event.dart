part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;
  final bool refresh; // Untuk pull-to-refresh
  const LoadNotifications({required this.userId, this.refresh = false});
   @override
  List<Object?> get props => [userId, refresh];
}

class LoadMoreNotifications extends NotificationEvent {
   final String userId;
  const LoadMoreNotifications({required this.userId});
   @override
  List<Object?> get props => [userId];
}

class MarkSingleNotificationRead extends NotificationEvent {
  final String notificationId;
  const MarkSingleNotificationRead(this.notificationId);
   @override
  List<Object?> get props => [notificationId];
}

class MarkAllUserNotificationsRead extends NotificationEvent {
  final String userId;
  const MarkAllUserNotificationsRead(this.userId);
   @override
  List<Object?> get props => [userId];
}

// Event internal untuk update dari stream notifikasi baru
class _NewNotificationReceived extends NotificationEvent {
  final NotificationEntity newNotification;
  const _NewNotificationReceived(this.newNotification);
   @override
  List<Object?> get props => [newNotification];
}

// Event internal untuk update dari stream unread count
class _UnreadCountUpdated extends NotificationEvent {
  final int unreadCount;
  const _UnreadCountUpdated(this.unreadCount);
   @override
  List<Object?> get props => [unreadCount];
}