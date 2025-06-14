import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:olivia/features/feedback/domain/entities/feedback.dart';
import 'package:olivia/features/feedback/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> submitFeedback(FeedbackEntity feedback) async {
    try {
      await remoteDataSource.submitFeedback(feedback);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure("Terjadi kesalahan tidak terduga."));
    }
  }
}
