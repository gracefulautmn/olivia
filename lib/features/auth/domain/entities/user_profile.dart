import 'package:equatable/equatable.dart';
import 'package:olivia/core/utils/enums.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? nim; // Nullable
  final String? major; // Nullable
  final String? avatarUrl; // Nullable

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.nim,
    this.major,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, nim, major, avatarUrl];
}