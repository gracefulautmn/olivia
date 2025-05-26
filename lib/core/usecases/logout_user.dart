// lib/features/auth/domain/usecases/logout_user.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:lost_and_found_app/core/errors/failures.dart';
import 'package:lost_and_found_app/core/usecases/usecase.dart'; // Base Usecase
import 'package:lost_and_found_app/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Tidak ada parameter yang dibutuhkan untuk logout
    return await repository.logoutUser();
  }
}
