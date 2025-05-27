import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<UserProfile?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, UserProfile?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
