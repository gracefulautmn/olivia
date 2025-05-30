import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/common_widgets/user_avatar.dart';

class ChatListItemWidget extends StatelessWidget {
  final ChatRoomEntity chatRoom;
  final VoidCallback onTap;

  const ChatListItemWidget({
    super.key,
    required this.chatRoom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = chatRoom.unreadCount > 0;
    final String lastMessageText =
        chatRoom.lastMessage?.content ?? 'Belum ada pesan';
    final DateTime lastMessageTime = chatRoom.lastMessageAt;

    return ListTile(
      onTap: onTap,
      leading: UserAvatar(
        imageUrl: chatRoom.otherParticipantAvatarUrl,
        initialName: chatRoom.otherParticipantName,
        radius: 26,
      ),
      title: Text(
        chatRoom.otherParticipantName ?? 'Pengguna Tidak Dikenal',
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          color:
              hasUnread
                  ? AppColors.textColor
                  : AppColors.textColor.withOpacity(0.9),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMessageText,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          color:
              hasUnread
                  ? AppColors.subtleTextColor.withOpacity(0.9)
                  : AppColors.subtleTextColor.withOpacity(0.7),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(lastMessageTime),
            style: TextStyle(
              fontSize: 12,
              color:
                  hasUnread
                      ? AppColors.primaryColor
                      : AppColors.subtleTextColor,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primaryColor,
              child: Text(
                chatRoom.unreadCount > 9
                    ? '9+'
                    : chatRoom.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 24), // Placeholder agar tinggi sama
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return DateFormat.Hm().format(timestamp); // Jam:Menit (e.g., 14:30)
    } else if (messageDate == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat(
        'dd/MM/yy',
      ).format(timestamp); // Tanggal (e.g., 23/10/23)
    }
  }
}
