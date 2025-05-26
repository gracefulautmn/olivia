// lib/features/auth/data/datasources/auth_remote_datasource_impl.dart

import 'dart:io'; // Untuk File saat upload avatar

import 'package:injectable/injectable.dart';
import 'package:olivia/core/config/app_constants.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<UserProfileModel> loginUser(LoginDataSourceParams params) async {
    try {
      final authResponse = await _supabaseClient.auth.signInWithPassword(
        email: params.email,
        password: params.password,
      );

      if (authResponse.user == null) {
        throw AuthenticationException(message: 'Login gagal: User tidak ditemukan setelah autentikasi.');
      }

      // Setelah login Supabase berhasil, ambil profil dari tabel 'profiles'
      // Ini penting karena tabel 'profiles' berisi data tambahan seperti peran, nim, jurusan.
      final userProfile = await getCurrentUserProfile();
      if (userProfile == null) {
        // Ini kasus yang aneh, user Supabase ada tapi profil di tabel 'profiles' tidak ada.
        // Bisa jadi karena trigger belum selesai atau ada masalah sinkronisasi.
        // Untuk keamanan, kita bisa logout user Supabase dan lempar error.
        await _supabaseClient.auth.signOut();
        throw AuthenticationException(message: 'Login berhasil tetapi profil pengguna tidak ditemukan. Silakan coba lagi atau hubungi admin.');
      }
      return userProfile;

    } on AuthException catch (e) {
      // Tangani error spesifik dari Supabase Auth
      // Pesan error dari Supabase biasanya sudah cukup deskriptif.
      // Contoh: "Invalid login credentials"
      throw AuthenticationException(message: e.message, statusCode: int.tryParse(e.statusCode ?? ""));
    } catch (e) {
      // Tangani error umum lainnya
      throw ServerException(message: 'Terjadi kesalahan saat login: ${e.toString()}');
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: 'Gagal logout: ${e.message}', statusCode: int.tryParse(e.statusCode ?? ""));
    } catch (e) {
      throw ServerException(message: 'Terjadi kesalahan saat logout: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel?> getCurrentUserProfile() async {
    final supabaseUser = _supabaseClient.auth.currentUser;
    if (supabaseUser == null) {
      return null; // Tidak ada pengguna yang login di Supabase
    }

    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id)
          .single(); // .single() akan error jika tidak ada atau lebih dari 1

      return UserProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') { // Kode error Postgrest untuk " esattamente una riga attesa, ma ne sono state trovate 0" (no rows found)
        // Atau bisa cek e.details atau e.hint jika tersedia dan lebih spesifik
        // Ini berarti user Supabase ada, tapi profil di tabel 'profiles' belum ada.
        // Bisa jadi karena trigger handle_new_user belum selesai atau gagal.
        throw NotFoundException(message: 'Profil pengguna tidak ditemukan di database.', statusCode: 404);
      }
      throw ServerException(message: 'Gagal mengambil profil: ${e.message}', statusCode: int.tryParse(e.code ?? ""));
    } catch (e) {
      throw ServerException(message: 'Terjadi kesalahan saat mengambil profil: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UpdateProfileDataSourceParams params) async {
    try {
      String? avatarUrl = params.avatarPath != null ? await _uploadAvatar(params.userId, params.avatarPath!) : null;

      Map<String, dynamic> dataToUpdate = {
        if (params.fullName != null) 'full_name': params.fullName,
        if (params.major != null) 'major': params.major,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(), // Update timestamp
      };

      // Hapus field yang nilainya null agar tidak menimpa data yang sudah ada dengan null
      // kecuali jika memang sengaja ingin di-set null (misal, menghapus major).
      // Untuk kasus ini, kita asumsikan null berarti tidak ada perubahan untuk field tersebut.
      dataToUpdate.removeWhere((key, value) => value == null && key != 'major' && key != 'avatar_url');
      // Jika 'major' atau 'avatar_url' dikirim sebagai null secara eksplisit,
      // maka field tersebut akan di-set null di database.

      if (dataToUpdate.isEmpty) {
        // Jika tidak ada data yang diupdate, kembalikan profil saat ini
        final currentProfile = await getCurrentUserProfile();
        if (currentProfile == null) throw ServerException(message: "Tidak dapat menemukan profil saat ini untuk update.");
        return currentProfile;
      }


      final response = await _supabaseClient
          .from('profiles')
          .update(dataToUpdate)
          .eq('id', params.userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Gagal update profil: ${e.message}', statusCode: int.tryParse(e.code ?? ""));
    } on StorageException catch (e) {
      throw ServerException(message: 'Gagal upload avatar: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Terjadi kesalahan saat update profil: ${e.toString()}');
    }
  }

  Future<String?> _uploadAvatar(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'public/$fileName'; // Simpan di dalam folder 'public' di bucket avatar

      await _supabaseClient.storage
          .from('item_images') // Ganti dengan nama bucket avatar Anda jika berbeda, misal 'avatars'
          .upload(path, file, fileOptions: const FileOptions(cacheControl: '3600', upsert: false));
      
      // Dapatkan URL publik dari gambar yang diupload
      final imageUrlResponse = _supabaseClient.storage
          .from('item_images') // Ganti dengan nama bucket avatar Anda
          .getPublicUrl(path);
      
      return imageUrlResponse;
    } on StorageException catch (e) {
      // Tangani error spesifik dari Supabase Storage
      // Misal: file terlalu besar, tipe tidak didukung, dll.
      throw StorageException(e.message, statusCode: e.statusCode ?? '500'); // Re-throw dengan detail
    } catch (e) {
      throw ServerException(message: 'Gagal mengupload avatar: ${e.toString()}');
    }
  }

  // @override
  // Stream<User?> get supabaseUserStream => _supabaseClient.auth.onAuthStateChange.map((authState) => authState.session?.user);

}
