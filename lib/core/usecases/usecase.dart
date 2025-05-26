// lib/core/usecases/usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';

// Interface abstrak untuk UseCase
// Type: Tipe data yang dikembalikan jika use case berhasil (Success Type)
// Params: Tipe data parameter yang dibutuhkan oleh use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Kelas NoParams digunakan jika use case tidak memerlukan parameter apapun.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
