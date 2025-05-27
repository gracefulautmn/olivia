import 'dart:io';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<UserProfileModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? major,
    File? avatarFile,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl({required this.supabaseClient});

  Future<String?> _uploadAvatar(File avatarFile, String userId) async {
    try {
      final fileName =
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.${avatarFile.path.split('.').last}';
      // Hapus avatar lama jika ada (opsional, butuh logika tambahan untuk fetch path lama)
      // await supabaseClient.storage.from('avatars').remove(['old_avatar_path']);

      final path = await supabaseClient.storage
          .from('avatars') // Nama bucket untuk avatar
          .upload(
            fileName,
            avatarFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ), // upsert true agar bisa replace
          );
      final publicUrl = supabaseClient.storage
          .from('avatars')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Error uploading avatar: $e");
      return null; // Atau throw ServerException jika upload wajib berhasil
    }
  }

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final response =
          await supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .single();
      return UserProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw ServerException(message: "Profil pengguna tidak ditemukan.");
      }
      print("Supabase error getting profile: ${e.message}");
      throw ServerException(message: "Gagal mengambil profil: ${e.message}");
    } catch (e) {
      print("General error getting profile: $e");
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? major,
    File? avatarFile,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {};
      if (fullName != null && fullName.isNotEmpty) {
        dataToUpdate['full_name'] = fullName;
      }
      // NIM dan role tidak diupdate dari sini, email juga
      // Major bisa diupdate, tapi perlu cek apakah user adalah mahasiswa
      if (major != null) {
        // Perlu validasi apakah user adalah mahasiswa di usecase/bloc
        dataToUpdate['major'] = major;
      }

      if (avatarFile != null) {
        final newAvatarUrl = await _uploadAvatar(avatarFile, userId);
        if (newAvatarUrl != null) {
          dataToUpdate['avatar_url'] = newAvatarUrl;
        }
      }

      if (dataToUpdate.isEmpty) {
        // Tidak ada yang diupdate, kembalikan profil saat ini
        return await getUserProfile(userId);
      }

      dataToUpdate['updated_at'] =
          DateTime.now()
              .toIso8601String(); // Update manual jika trigger tidak ada

      final response =
          await supabaseClient
              .from('profiles')
              .update(dataToUpdate)
              .eq('id', userId)
              .select()
              .single();
      return UserProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      print("Supabase error updating profile: ${e.message}");
      throw ServerException(message: "Gagal memperbarui profil: ${e.message}");
    } catch (e) {
      print("General error updating profile: $e");
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }
}
