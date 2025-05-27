// Tidak menggunakan Either karena stream akan menangani error atau data secara berkelanjutan
// atau jika ingin konsisten dengan Either, stream bisa mengembalikan Either<Failure, UserProfile?>
// tapi lebih umum stream langsung emit data atau error.
// Di sini, kita akan buat repository yang mengembalikan Stream<UserProfile?>
// dan use case hanya meneruskannya.

import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';

// Jika ingin tetap menggunakan struktur UseCase<Type, Params>
// Type akan menjadi Stream<UserProfile?>
// Params akan menjadi NoParams
// Namun, method call() biasanya Future.

// Alternatif 1: Langsung return stream dari repository
class GetAuthStateChanges {
  // Tidak mengimplementasikan UseCase
  final AuthRepository repository;

  GetAuthStateChanges(this.repository);

  Stream<UserProfile?> call(NoParams params) {
    return repository.authStateChanges;
  }
}

/*
// Alternatif 2: Jika ingin "memaksa" ke interface UseCase,
// meskipun 'call' biasanya mengembalikan Future.
// Ini mungkin kurang intuitif karena 'call' akan mengembalikan Future<Stream>.
// Namun, untuk konsistensi di DI dan pemanggilan, bisa saja.
// Di BLoC, kita akan listen ke hasil stream dari Future tersebut.

import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStateChanges implements UseCase<Stream<UserProfile?>, NoParams> {
  final AuthRepository repository;

  GetAuthStateChanges(this.repository);

  @override
  Future<Either<Failure, Stream<UserProfile?>>> call(NoParams params) async {
    // Dalam kasus ini, karena repository.authStateChanges langsung Stream,
    // kita bisa wrap dalam Right.
    // Tidak ada operasi async yang bisa gagal di sini sebelum mendapatkan stream-nya.
    try {
      return Right(repository.authStateChanges);
    } catch (e) {
      // Ini kecil kemungkinannya terjadi jika repository.authStateChanges hanya getter.
      return Left(UnknownFailure("Failed to get auth state stream: ${e.toString()}"));
    }
  }
}
*/

// Pilihan yang lebih umum dan disarankan untuk stream adalah **Alternatif 1**.
// BLoC akan langsung menggunakan stream ini.
// Di AuthBloc, kita sudah menggunakan pendekatan ini:
// _authStateChangesSubscription = _getAuthStateChanges(NoParams()).listen(...)
// Jadi, Alternatif 1 adalah yang paling sesuai dengan implementasi AuthBloc yang sudah ada.
