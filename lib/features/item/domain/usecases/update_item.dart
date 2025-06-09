import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

// Asumsi Anda sudah mendaftarkan use case ini di service_locator
class UpdateItem implements UseCase<ItemEntity, UpdateItemParams> {
  final ItemRepository repository;

  UpdateItem(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(UpdateItemParams params) async {
    // Memanggil repository dengan parameter yang sesuai dengan definisi Anda
    return await repository.updateItem(params.item, newImageFile: params.newImageFile);
  }
}

// Params disesuaikan agar cocok dengan signature di ItemRepository Anda
class UpdateItemParams extends Equatable {
  final ItemEntity item;
  final File? newImageFile;

  const UpdateItemParams({
    required this.item,
    this.newImageFile,
  });

  @override
  List<Object?> get props => [item, newImageFile];
}
