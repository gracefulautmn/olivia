import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart' as core_exceptions; // Alias sudah digunakan
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
    // TODO: Pertimbangkan untuk uncomment dan implementasi pengecekan networkInfo
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure("Tidak ada koneksi internet."));
    // }
    try {
      final userProfileModel =
          await remoteDataSource.loginUser(email: email, password: password);
      return Right(userProfileModel);
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message)); // Mengembalikan AuthFailure dengan pesan dari exception
    } on core_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message)); // Mengembalikan ServerFailure dengan pesan dari exception
    } catch (e) {
      print("AuthRepositoryImpl - loginUser - Unknown Error: $e"); // Tambahkan log untuk debug
      return Left(UnknownFailure("Terjadi kesalahan tak terduga saat login: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signUpUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // TODO: Pertimbangkan untuk uncomment dan implementasi pengecekan networkInfo
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure("Tidak ada koneksi internet."));
    // }
    try {
      final userProfileModel = await remoteDataSource.signUpUser(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(userProfileModel);
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message)); // Mengembalikan AuthFailure dengan pesan dari exception
    } on core_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message)); // Mengembalikan ServerFailure dengan pesan dari exception
    } catch (e) {
      print("AuthRepositoryImpl - signUpUser - Unknown Error: $e"); // Tambahkan log untuk debug
      return Left(UnknownFailure("Pendaftaran gagal karena kesalahan tak terduga: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getCurrentUser() async {
    // Pengecekan networkInfo mungkin tidak selalu diperlukan di sini jika ini hanya mengambil data dari cache lokal Supabase client
    // Tapi jika selalu hit network, maka perlu.
    try {
      final userProfileModel = await remoteDataSource.getCurrentUser();
      return Right(userProfileModel);
    } on core_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      print("AuthRepositoryImpl - getCurrentUser - Unknown Error: $e");
      return Left(UnknownFailure("Gagal mengambil data pengguna saat ini: ${e.toString()}"));
    }
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    // Tidak ada error handling di sini karena stream dari datasource yang akan handle error atau emit data.
    // BLoC yang akan subscribe ke stream ini dan menangani Either<Failure, UserProfile?> jika repository diubah untuk emit itu.
    // Untuk sekarang, kita asumsikan datasource.authStateChanges mengembalikan UserProfileModel? dan mapping langsung.
    return remoteDataSource.authStateChanges;
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    // TODO: Pertimbangkan untuk uncomment dan implementasi pengecekan networkInfo
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure("Tidak ada koneksi internet."));
    // }
    try {
      await remoteDataSource.logoutUser();
      return const Right(null);
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on core_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      print("AuthRepositoryImpl - logoutUser - Unknown Error: $e");
      return Left(UnknownFailure("Gagal logout karena kesalahan tak terduga: ${e.toString()}"));
    }
  }
}