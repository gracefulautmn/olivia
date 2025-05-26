// lib/features/auth/domain/usecases/login_user.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart'; // Base Usecase
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';

// Parameter untuk LoginUser use case, sama dengan LoginParams di repository
// Kita bisa menggunakan kembali LoginParams dari repository atau membuat yang baru di sini
// jika ada perbedaan. Untuk kasus ini, kita bisa gunakan yang sama.
// Jika Anda ingin lebih strict, Anda bisa mendefinisikan Params class di sini
// dan melakukan mapping di AuthCubit atau di dalam use case.
// Untuk kesederhanaan, kita akan gunakan LoginParams dari repository.

@lazySingleton
class LoginUser implements UseCase<UserProfile, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(LoginParams params) async {
    // Di sini bisa ditambahkan validasi input tambahan jika diperlukan,
    // sebelum memanggil repository.
    // Misalnya, validasi format email yang lebih spesifik,
    // atau panjang password, dll.
    // Namun, validasi dasar (seperti format email UP) sudah ada di AuthCubit.

    return await repository.loginUser(params);
  }
}

// Jika Anda memilih untuk membuat Params class sendiri untuk use case:
// class LoginUserParams extends Equatable {
//   final String email;
//   final String password;

//   const LoginUserParams({required this.email, required this.password});

//   @override
//   List<Object> get props => [email, password];
// }
