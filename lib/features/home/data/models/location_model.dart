import 'package:olivia/features/home/domain/entities/location.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.name,
    // super.iconIdentifier,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      // iconIdentifier: json['icon_identifier'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'icon_identifier': iconIdentifier,
    };
  }
}
