// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/network/network_info.dart'; // Akan kita buat
import 'package:olivia/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // Untuk AuthException

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Untuk memeriksa koneksi internet

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> loginUser(LoginParams params) async {
    if (await networkInfo.isConnected) {
      try {
        // Meneruskan parameter ke datasource
        final userProfileModel = await remoteDataSource.loginUser(
          LoginDataSourceParams(email: params.email, password: params.password),
        );
        // UserProfileModel sudah merupakan turunan dari UserProfile, jadi bisa langsung dikembalikan
        return Right(userProfileModel);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message, statusCode: e.statusCode));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } on NotFoundException catch (e) { // Jika getCurrentUserProfile di dalam loginUser melempar ini
        return Left(NotFoundFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        // Tangkap error tak terduga lainnya
        return Left(UnexpectedFailure(message: "Terjadi kesalahan tidak terduga saat login: ${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.logoutUser();
        return const Right(null); // Sukses logout, tidak ada data spesifik untuk dikembalikan
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(UnexpectedFailure(message: "Terjadi kesalahan tidak terduga saat logout: ${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getCurrentUserProfile() async {
    // Pengecekan koneksi mungkin tidak selalu diperlukan di sini jika kita
    // ingin mencoba mengambil dari cache terlebih dahulu (jika ada implementasi cache).
    // Namun, karena ini mengambil profil dari remote, pengecekan koneksi tetap relevan.
    if (await networkInfo.isConnected) {
      try {
        final userProfileModel = await remoteDataSource.getCurrentUserProfile();
        // userProfileModel bisa null jika tidak ada user Supabase yang login
        return Right(userProfileModel);
      } on NotFoundException catch (e) {
        // Jika user Supabase ada, tapi profil di tabel 'profiles' tidak ditemukan
        return Left(NotFoundFailure(message: e.message, statusCode: e.statusCode));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(UnexpectedFailure(message: "Gagal mengambil profil pengguna saat ini: ${e.toString()}"));
      }
    } else {
      // Jika tidak ada koneksi, kita bisa mengembalikan null atau Failure spesifik.
      // Mengembalikan NetworkFailure lebih konsisten.
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(UpdateProfileParams params) async {
    if (await networkInfo.isConnected) {
      try {
        // Meneruskan parameter ke datasource
        final updatedUserProfileModel = await remoteDataSource.updateUserProfile(
          UpdateProfileDataSourceParams(
            userId: params.userId,
            fullName: params.fullName,
            major: params.major,
            avatarPath: params.avatarPath,
          ),
        );
        return Right(updatedUserProfileModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } on InvalidInputException catch (e) { // Jika datasource melempar ini
        return Left(InvalidInputFailure(message: e.message));
      } catch (e) {
         return Left(UnexpectedFailure(message: "Gagal memperbarui profil: ${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
