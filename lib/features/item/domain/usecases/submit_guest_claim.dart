import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

// Asumsi Anda sudah mendaftarkan use case ini di service_locator
class SubmitGuestClaim implements UseCase<void, SubmitGuestClaimParams> {
  final ItemRepository repository;

  SubmitGuestClaim(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitGuestClaimParams params) async {
    // Memanggil metode di repository untuk memproses klaim oleh tamu
    return await repository.submitGuestClaim(params);
  }
}

class SubmitGuestClaimParams extends Equatable {
  final String itemId;
  final String securityId; // ID Keamanan yang memproses
  final String guestDetails; // Informasi tamu (Nama, Kontak, dll.)

  const SubmitGuestClaimParams({
    required this.itemId,
    required this.securityId,
    required this.guestDetails,
  });

  @override
  List<Object?> get props => [itemId, securityId, guestDetails];
}
