import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String id;
  final String name;
  // final String? iconIdentifier;

  const LocationEntity({
    required this.id,
    required this.name,
    // this.iconIdentifier,
  });

  @override
  List<Object?> get props => [id, name];
}