import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

// Asumsi sudah didaftarkan di service_locator
class GetGlobalClaimHistory implements UseCase<List<ClaimHistoryEntry>, NoParams> {
  final ItemRepository repository;

  GetGlobalClaimHistory(this.repository);

  @override
  Future<Either<Failure, List<ClaimHistoryEntry>>> call(NoParams params) async {
    return await repository.getGlobalClaimHistory();
  }
}
