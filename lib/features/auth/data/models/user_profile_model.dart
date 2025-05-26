// lib/features/auth/data/models/user_profile_model.dart

import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // Untuk User Supabase

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.nim,
    super.major,
    super.avatarUrl,
    super.updatedAt,
  });

  // Factory constructor untuk membuat UserProfileModel dari JSON (data dari Supabase 'profiles' table)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: _parseUserRole(json['role'] as String?),
      nim: json['nim'] as String?,
      major: json['major'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal() // Konversi ke waktu lokal
          : null,
    );
  }

  // Method untuk mengubah UserProfileModel menjadi JSON (untuk mengirim data ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name, // Menggunakan .name dari enum untuk mendapatkan string
      'nim': nim,
      'major': major,
      'avatar_url': avatarUrl,
      // 'updated_at' biasanya di-handle oleh database (trigger atau default value)
    };
  }

  // Helper untuk parsing string role dari JSON ke enum UserRole
  static UserRole _parseUserRole(String? roleString) {
    if (roleString == 'mahasiswa') {
      return UserRole.mahasiswa;
    } else if (roleString == 'staff_dosen') {
      return UserRole.staffDosen;
    }
    return UserRole.unknown; // Default jika tidak dikenali
  }

  // (Opsional) Factory constructor untuk membuat UserProfileModel dari Supabase User object
  // Ini berguna jika Anda ingin membuat profil awal hanya dari data auth Supabase,
  // meskipun idealnya semua data profil berasal dari tabel 'profiles' kita.
  factory UserProfileModel.fromSupabaseUser(supabase.User supabaseUser, {String? initialFullName, UserRole? initialRole, String? initialNim}) {
    UserRole determinedRole = initialRole ?? UserRole.unknown;
    String? nim = initialNim;

    if (supabaseUser.email != null) {
        if (supabaseUser.email!.contains('@student.universitaspertamina.ac.id')) {
            determinedRole = UserRole.mahasiswa;
            nim = supabaseUser.email!.split('@').first;
        } else if (supabaseUser.email!.contains('@universitaspertamina.ac.id')) {
            determinedRole = UserRole.staffDosen;
        }
    }

    return UserProfileModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: initialFullName ?? supabaseUser.userMetadata?['full_name'] as String? ?? 'New User',
      role: determinedRole,
      nim: nim,
      // major, avatarUrl, updatedAt akan null atau diisi nanti saat profil diupdate
    );
  }
}
