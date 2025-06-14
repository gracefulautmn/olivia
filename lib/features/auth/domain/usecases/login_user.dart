import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';

class LoginUser implements UseCase<UserProfile, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(LoginParams params) async {
    // Tambahkan validasi email di sini jika perlu, atau di BLoC/Page
    if (!params.email.endsWith('@student.universitaspertamina.ac.id') &&
        !params.email.endsWith('@universitaspertamina.ac.id') && 
        !params.email.endsWith('@security.universitaspertamina.ac.id')) {
      return Left(
        InputValidationFailure(
          'Email harus menggunakan domain universitaspertamina.ac.id',
        ),
      );
    }
    if (params.password.isEmpty) {
      return Left(InputValidationFailure('Password tidak boleh kosong'));
    }
    return await repository.loginUser(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
