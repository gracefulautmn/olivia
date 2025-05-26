// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:olivia/features/auth/data/models/user_profile_model.dart';
// Parameter akan kita definisikan di sini atau impor dari repository jika sama persis
// Untuk saat ini, kita asumsikan parameter yang dibutuhkan datasource mirip dengan repository

// Parameter untuk login (bisa sama dengan LoginParams di repository)
class LoginDataSourceParams {
  final String email;
  final String password;

  LoginDataSourceParams({required this.email, required this.password});
}

// Parameter untuk update profil (bisa sama dengan UpdateProfileParams di repository)
class UpdateProfileDataSourceParams {
  final String userId;
  final String? fullName;
  final String? major;
  final String? avatarPath; // Path file lokal jika ada avatar baru yang diupload

  UpdateProfileDataSourceParams({
    required this.userId,
    this.fullName,
    this.major,
    this.avatarPath,
  });
}


abstract class AuthRemoteDataSource {
  /// Melakukan login pengguna menggunakan email dan password.
  ///
  /// Melemparkan [ServerException] atau [AuthenticationException] jika terjadi error.
  Future<UserProfileModel> loginUser(LoginDataSourceParams params);

  /// Melakukan logout pengguna saat ini.
  ///
  /// Melemparkan [ServerException] jika terjadi error.
  Future<void> logoutUser();

  /// Mendapatkan profil pengguna yang sedang login dari tabel 'profiles'.
  ///
  /// Melemparkan [ServerException] jika terjadi error atau [NotFoundException] jika profil tidak ada.
  /// Mengembalikan `null` jika tidak ada user yang sedang login di Supabase.
  Future<UserProfileModel?> getCurrentUserProfile();

  /// Mengupdate profil pengguna di tabel 'profiles'.
  /// Jika `avatarPath` diberikan, akan mengupload avatar baru ke Supabase Storage.
  ///
  /// Melemparkan [ServerException] jika terjadi error.
  Future<UserProfileModel> updateUserProfile(UpdateProfileDataSourceParams params);

  // (Opsional) Stream untuk mendengarkan perubahan user dari Supabase Auth
  // Stream<supabase.User?> get supabaseUserStream;
}
