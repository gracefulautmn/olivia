import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';

// Fungsi helper ini harus ada di file enums.dart atau di sini
UserRole userRoleFromString(String value) {
  if (value == 'mahasiswa') return UserRole.mahasiswa;
  if (value == 'staff_dosen') return UserRole.staff_dosen;
  if (value == 'keamanan') return UserRole.keamanan;
  return UserRole.mahasiswa; // Default
}

String userRoleToString(UserRole role) {
  return role.name;
}

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.nim,
    super.major,
    super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      // PERBAIKAN: Berikan nilai default jika null
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? 'Tidak ada email',
      fullName: json['full_name']?.toString() ?? 'Nama Tidak Diketahui',
      role: userRoleFromString(json['role']?.toString() ?? 'mahasiswa'),
      nim: json['nim']?.toString(),
      major: json['major']?.toString(),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': userRoleToString(role),
      'nim': nim,
      'major': major,
      'avatar_url': avatarUrl,
    };
  }
}
