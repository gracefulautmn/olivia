import 'dart:io'; // Untuk File gambar avatar
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required String userId,
    String? fullName,
    String? major, // Hanya untuk mahasiswa
    File? avatarFile, // File gambar avatar baru
  });
  // Jika ada data profil lain yang bisa diupdate, tambahkan di sini
}
