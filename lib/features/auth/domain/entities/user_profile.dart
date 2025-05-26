// lib/features/auth/domain/entities/user_profile.dart

import 'package:equatable/equatable.dart';

// Enum untuk peran pengguna, sesuai dengan yang di database
enum UserRole {
  mahasiswa,
  staffDosen,
  unknown // Untuk kasus default atau error parsing
}

class UserProfile extends Equatable {
  final String id; // UUID dari Supabase auth.users
  final String email;
  final String fullName;
  final UserRole role;
  final String? nim; // Nomor Induk Mahasiswa, bisa null
  final String? major; // Jurusan, bisa null
  final String? avatarUrl; // URL foto profil
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.nim,
    this.major,
    this.avatarUrl,
    this.updatedAt,
  });

  // Helper untuk menentukan apakah pengguna adalah mahasiswa
  bool get isStudent => role == UserRole.mahasiswa;

  // Helper untuk mendapatkan inisial nama (misal, untuk avatar fallback)
  String get initials {
    if (fullName.isEmpty) return '?';
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        role,
        nim,
        major,
        avatarUrl,
        updatedAt,
      ];

  // (Opsional)copyWith method untuk memudahkan update instance
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? nim,
    bool clearNim = false, // Untuk menghapus NIM
    String? major,
    bool clearMajor = false, // Untuk menghapus Jurusan
    String? avatarUrl,
    bool clearAvatarUrl = false, // Untuk menghapus Avatar URL
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      nim: clearNim ? null : (nim ?? this.nim),
      major: clearMajor ? null : (major ?? this.major),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
