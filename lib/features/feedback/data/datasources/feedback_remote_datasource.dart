import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/features/feedback/domain/entities/feedback.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FeedbackRemoteDataSource {
  Future<void> submitFeedback(FeedbackEntity feedback);
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final SupabaseClient supabaseClient;

  FeedbackRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> submitFeedback(FeedbackEntity feedback) async {
    try {
      final feedbackData = {
        'user_id': feedback.userId,
        'feedback_type': feedback.feedbackType,
        'content': feedback.content,
      };
      await supabaseClient.from('feedback').insert(feedbackData);
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal mengirim feedback: ${e.message}");
    } catch (e) {
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }
}
