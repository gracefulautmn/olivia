import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/core/utils/enums.dart'; // <-- Pastikan import ini ada
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

// --- PERBAIKAN PADA USE CASE ---
class UpdateItem implements UseCase<ItemEntity, UpdateItemParams> {
  final ItemRepository repository;

  UpdateItem(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(UpdateItemParams params) async {
    // Untuk memenuhi signature repository.updateItem, kita rakit sebuah ItemEntity
    // dari parameter yang diterima.
    // Repository di lapisan data hanya akan menggunakan ID dan field yang relevan untuk update.
    final itemToUpdate = ItemEntity(
      id: params.itemId,
      itemName: params.itemName,
      description: params.description,
      categoryId: params.categoryId,
      locationId: params.locationId,
      // Field di bawah ini tidak diperlukan untuk logika update,
      // tetapi harus diisi untuk membuat objek ItemEntity.
      reporterId: '', 
      reportType: ReportType.kehilangan, // Nilai placeholder
      status: ItemStatus.hilang, // Nilai placeholder
    );

    return await repository.updateItem(itemToUpdate, newImageFile: params.newImageFile);
  }
}

// --- PERBAIKAN PADA PARAMS ---
class UpdateItemParams extends Equatable {
  final String itemId;
  final String itemName;
  final String? description;
  final String? categoryId;
  final String locationId;
  final File? newImageFile;

  const UpdateItemParams({
    required this.itemId,
    required this.itemName,
    this.description,
    this.categoryId,
    required this.locationId,
    this.newImageFile,
  });

  @override
  List<Object?> get props => [
        itemId,
        itemName,
        description,
        categoryId,
        locationId,
        newImageFile,
      ];
}
