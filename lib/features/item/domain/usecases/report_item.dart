import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

class ReportItem implements UseCase<ItemEntity, ReportItemParams> {
  final ItemRepository repository;

  ReportItem(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(ReportItemParams params) async {
    if (params.itemName.isEmpty) {
      return Left(InputValidationFailure("Nama barang tidak boleh kosong."));
    }
    // Tambahkan validasi lain jika perlu
    return await repository.reportItem(
      reporterId: params.reporterId,
      itemName: params.itemName,
      description: params.description,
      categoryId: params.categoryId,
      locationId: params.locationId,
      reportType: params.reportType,
      imageFile: params.imageFile,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class ReportItemParams extends Equatable {
  final String reporterId;
  final String itemName;
  final String? description;
  final String? categoryId;
  final String? locationId;
  final String reportType; // 'kehilangan' atau 'penemuan'
  final File? imageFile;
  final double? latitude;
  final double? longitude;

  const ReportItemParams({
    required this.reporterId,
    required this.itemName,
    this.description,
    this.categoryId,
    this.locationId,
    required this.reportType,
    this.imageFile,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    reporterId,
    itemName,
    description,
    categoryId,
    locationId,
    reportType,
    imageFile,
    latitude,
    longitude,
  ];
}
