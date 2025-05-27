import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:olivia/features/profile/domain/repositories/profile_repository.dart';
// import 'package:olivia/core/network/network_info.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    // if (await networkInfo.isConnected) {
      try {
        final userProfileModel = await remoteDataSource.getUserProfile(userId);
        return Right(userProfileModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
      }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required String userId,
    String? fullName,
    String? major,
    File? avatarFile,
  }) async {
    // if (await networkInfo.isConnected) {
      try {
        final userProfileModel = await remoteDataSource.updateUserProfile(
          userId: userId,
          fullName: fullName,
          major: major,
          avatarFile: avatarFile,
        );
        return Right(userProfileModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
      }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }
}