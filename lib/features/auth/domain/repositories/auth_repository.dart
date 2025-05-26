// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';

// Parameter untuk login
class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

// Parameter untuk update profil
class UpdateProfileParams {
  final String userId; // Dibutuhkan untuk tahu profil siapa yang diupdate
  final String? fullName;
  final String? major; // Bisa null
  final String? avatarPath; // Path file lokal jika ada avatar baru yang diupload

  UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.major,
    this.avatarPath,
  });
}

abstract class AuthRepository {
  // Mendengarkan perubahan status autentikasi dari Supabase
  // Stream<Either<Failure, UserProfile?>> get authStateChanges; // Alternatif jika ingin handle profil via stream repository

  // Login pengguna dengan email dan password
  Future<Either<Failure, UserProfile>> loginUser(LoginParams params);

  // Logout pengguna saat ini
  Future<Either<Failure, void>> logoutUser();

  // Mendapatkan profil pengguna yang sedang login
  Future<Either<Failure, UserProfile?>> getCurrentUserProfile();

  // Mengupdate profil pengguna
  Future<Either<Failure, UserProfile>> updateUserProfile(UpdateProfileParams params);

  // (Opsional) Sign up pengguna baru jika diperlukan di masa depan
  // Future<Either<Failure, UserProfile>> signUpUser(SignUpParams params);
}
