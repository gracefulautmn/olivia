import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/notification/domain/entities/notification.dart';

class NotificationListItemWidget extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationListItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'item_match':
        return Icons.find_in_page_outlined;
      case 'claim_received':
        return Icons.check_circle_outline;
      case 'new_message':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material( // Tambahkan Material agar InkWell bekerja dengan baik di atas warna
      color: notification.isRead ? Theme.of(context).canvasColor : AppColors.primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: notification.isRead 
                    ? Colors.grey.shade300 
                    : AppColors.primaryColor.withOpacity(0.8),
                foregroundColor: notification.isRead ? Colors.grey.shade700 : Colors.white,
                child: Icon(_getIconForType(notification.type), size: 24),
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        color: notification.isRead ? AppColors.textColor.withOpacity(0.85) : AppColors.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: notification.isRead ? AppColors.subtleTextColor : AppColors.subtleTextColor.withOpacity(0.9),
                         fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimestamp(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

   String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}d lalu';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }
  }
}