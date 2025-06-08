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

  String get initials {
    if (fullName.isEmpty) return '?';
    List<String> nameParts = fullName.trim().split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts.last[0].toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return '?';
  }
  
  @override
  List<Object?> get props => [id, email, fullName, role, nim, major, avatarUrl];
}