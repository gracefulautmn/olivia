import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/repositories/home_repository.dart';

class GetLocations implements UseCase<List<LocationEntity>, NoParams> {
  final HomeRepository repository;

  GetLocations(this.repository);

  @override
  Future<Either<Failure, List<LocationEntity>>> call(NoParams params) async {
    return await repository.getLocations();
  }
}
