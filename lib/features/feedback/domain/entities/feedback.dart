import 'package:equatable/equatable.dart';

// Enum ini sebaiknya ada di file enums.dart global Anda
// enum FeedbackType { bug, saran, review }

class FeedbackEntity extends Equatable {
  final String userId;
  final String feedbackType; // 'bug', 'saran', atau 'review'
  final String content;

  const FeedbackEntity({
    required this.userId,
    required this.feedbackType,
    required this.content,
  });

  @override
  List<Object?> get props => [userId, feedbackType, content];
}
