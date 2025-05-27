import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  // final String? iconIdentifier; // Jika Anda punya ikon lokal yang termapping

  const CategoryEntity({
    required this.id,
    required this.name,
    // this.iconIdentifier,
  });

  @override
  List<Object?> get props => [id, name];
}