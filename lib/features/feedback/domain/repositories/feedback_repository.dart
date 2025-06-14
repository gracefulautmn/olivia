import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/feedback/domain/entities/feedback.dart';

abstract class FeedbackRepository {
  Future<Either<Failure, void>> submitFeedback(FeedbackEntity feedback);
}
