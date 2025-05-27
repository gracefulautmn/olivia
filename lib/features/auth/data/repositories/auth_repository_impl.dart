import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';
// import 'package:olivia/core/network/network_info.dart'; // Jika digunakan

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Opsional, jika ingin cek koneksi

  AuthRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> loginUser({
    required String email,
    required String password,
  }) async {
    // if (await networkInfo.isConnected) { // Contoh penggunaan NetworkInfo
      try {
        final userProfileModel =
            await remoteDataSource.loginUser(email: email, password: password);
        return Right(userProfileModel); // Model adalah subtipe dari Entity
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch(e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
      }
    // } else {
    //   return Left(NetworkFailure("No internet connection."));
    // }
  }

  @override
  Future<Either<Failure, UserProfile?>> getCurrentUser() async {
    try {
      final userProfileModel = await remoteDataSource.getCurrentUser();
      return Right(userProfileModel);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
    }
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) => userModel);
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    try {
      await remoteDataSource.logoutUser();
      return const Right(null);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
    }
  }
}