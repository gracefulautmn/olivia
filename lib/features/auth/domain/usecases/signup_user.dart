import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart'; // Ganti 'olivia' dengan nama proyek Anda
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart'; // Atau User jika Anda punya entitas User sederhana untuk AuthResponse
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';

class SignUpUser implements UseCase<UserProfile, SignUpParams> { // Mengembalikan UserProfile setelah profil dibuat
  final AuthRepository repository;

  SignUpUser(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(SignUpParams params) async {
    // Validasi dasar di sini (opsional, bisa juga di BLoC/UI)
    if (params.password != params.confirmPassword) {
      return Left(InputValidationFailure("Password dan konfirmasi password tidak cocok."));
    }
    if (params.password.length < 6) {
      return Left(InputValidationFailure("Password minimal 6 karakter."));
    }
    if (params.fullName.isEmpty) {
      return Left(InputValidationFailure("Nama lengkap tidak boleh kosong."));
    }
     // Validasi email domain (seperti di LoginUser)
    if (!params.email.toLowerCase().endsWith('@student.universitaspertamina.ac.id') &&
        !params.email.toLowerCase().endsWith('@universitaspertamina.ac.id')) { // Sesuaikan domain Anda
      return Left(InputValidationFailure(
          'Email harus menggunakan domain @student.universitaspertamina.ac.id atau @universitaspertamina.ac.id'));
    }

    return await repository.signUpUser(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      // Anda bisa tambahkan data lain di sini jika perlu dikirim ke raw_user_meta_data
      // dan ditangkap oleh trigger handle_new_user
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
  });

  @override
  List<Object> get props => [email, password, confirmPassword, fullName];
}