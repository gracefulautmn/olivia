import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfile
    implements UseCase<UserProfile, UpdateUserProfileParams> {
  final ProfileRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(
    UpdateUserProfileParams params,
  ) async {
    if (params.userId.isEmpty) {
      return Left(AuthFailure("User ID tidak valid untuk update."));
    }
    // Tambahkan validasi lain jika perlu, misal fullName tidak boleh kosong jika diubah
    return await repository.updateUserProfile(
      userId: params.userId,
      fullName: params.fullName,
      major: params.major,
      avatarFile: params.avatarFile,
    );
  }
}

class UpdateUserProfileParams extends Equatable {
  final String userId;
  final String? fullName;
  final String? major;
  final File? avatarFile;
  // Tambahkan field lain yang bisa diupdate

  const UpdateUserProfileParams({
    required this.userId,
    this.fullName,
    this.major,
    this.avatarFile,
  });

  @override
  List<Object?> get props => [userId, fullName, major, avatarFile];
}
