import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserProfile>> loginUser({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserProfile?>> getCurrentUser();
  Stream<UserProfile?> get authStateChanges; // Untuk memantau status login
  Future<Either<Failure, void>> logoutUser();
}