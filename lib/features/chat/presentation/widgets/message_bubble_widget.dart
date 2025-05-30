import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olivia/core/utils/app_colors.dart';

class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  // final String? senderName; // Untuk group chat

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    // this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? AppColors.primaryColor : Colors.grey[200];
    final textColor = isMe ? Colors.white : AppColors.textColor;
    final borderRadius =
        isMe
            ? const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topRight: Radius.circular(
                4,
              ), // Sudut lebih tajam untuk pesan sendiri
            )
            : const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topLeft: Radius.circular(
                4,
              ), // Sudut lebih tajam untuk pesan orang lain
            );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: <Widget>[
          // if (senderName != null && !isMe) ...[ // Tampilkan nama jika group chat & bukan pesan sendiri
          //   Padding(
          //     padding: const EdgeInsets.only(left: 50.0, bottom: 2.0),
          //     child: Text(
          //       senderName!,
          //       style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
          //     ),
          //   ),
          // ],
          Row(
            // Agar bubble tidak full width
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                // Batasi lebar bubble
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 14.0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Teks selalu dari kiri
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15.5,
                          height: 1.3,
                        ),
                        textAlign:
                            TextAlign
                                .left, // Teks selalu rata kiri dalam bubble
                      ),
                      // const SizedBox(height: 4.0), // Jarak antara teks dan timestamp bisa dihilangkan
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding:
                isMe
                    ? const EdgeInsets.only(top: 3.0, right: 6.0)
                    : const EdgeInsets.only(top: 3.0, left: 6.0),
            child: Text(
              DateFormat.Hm().format(timestamp), // Hanya jam dan menit
              style: TextStyle(fontSize: 11.0, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
