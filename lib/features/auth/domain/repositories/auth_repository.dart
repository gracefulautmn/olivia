import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserProfile>> loginUser({
    required String email,
    required String password,
  });

  // Tambahkan method signUpUser
  Future<Either<Failure, UserProfile>> signUpUser({
    required String email,
    required String password,
    required String fullName,
    // Map<String, dynamic>? userMetadata, // Opsional jika ada data lain
  });

  Future<Either<Failure, UserProfile?>> getCurrentUser();
  Stream<UserProfile?> get authStateChanges;
  Future<Either<Failure, void>> logoutUser();
}