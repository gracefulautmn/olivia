import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/feedback/domain/entities/feedback.dart';
import 'package:olivia/features/feedback/domain/repositories/feedback_repository.dart';

class SubmitFeedback implements UseCase<void, FeedbackEntity> {
  final FeedbackRepository repository;

  SubmitFeedback(this.repository);

  @override
  Future<Either<Failure, void>> call(FeedbackEntity params) async {
    return await repository.submitFeedback(params);
  }
}
