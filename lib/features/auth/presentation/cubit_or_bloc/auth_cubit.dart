// lib/features/auth/presentation/cubit_or_bloc/auth_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:olivia/core/config/app_constants.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Impor use case (akan dibuat nanti, untuk sekarang kita buat placeholder)
// import 'package:olivia/features/auth/domain/usecases/login_user.dart';
// import 'package:olivia/features/auth/domain/usecases/logout_user.dart';
// import 'package:olivia/features/auth/domain/usecases/get_current_user_profile.dart';
// import 'package:olivia/features/auth/domain/usecases/update_user_profile.dart';

part 'auth_state.dart'; // State yang sudah kita buat sebelumnya

@injectable
class AuthCubit extends Cubit<AuthState> {
  final supabase.SupabaseClient _supabaseClient;
  // final LoginUser _loginUser; // Akan di-inject nanti
  // final LogoutUser _logoutUser; // Akan di-inject nanti
  // final GetCurrentUserProfile _getCurrentUserProfile; // Akan di-inject nanti
  // final UpdateUserProfile _updateUserProfile; // Akan di-inject nanti

  StreamSubscription<supabase.AuthState>? _authStateSubscription;

  AuthCubit({
    required supabase.SupabaseClient supabaseClient,
    // required LoginUser loginUser,
    // required LogoutUser logoutUser,
    // required GetCurrentUserProfile getCurrentUserProfile,
    // required UpdateUserProfile updateUserProfile,
  })  : _supabaseClient = supabaseClient,
        // _loginUser = loginUser,
        // _logoutUser = logoutUser,
        // _getCurrentUserProfile = getCurrentUserProfile,
        // _updateUserProfile = updateUserProfile,
        super(AuthInitial()) {
    _monitorAuthState();
  }

  void _monitorAuthState() {
    _authStateSubscription =
        _supabaseClient.auth.onAuthStateChange.listen((supabase.AuthState data) async {
      final supabase.User? user = data.session?.user;
      if (user != null) {
        // Pengguna terautentikasi oleh Supabase
        // Di sini kita idealnya memanggil GetCurrentUserProfile use case
        // Untuk sekarang, kita buat UserProfile dummy atau coba ambil dari Supabase user
        try {
          // Placeholder: Idealnya ini dari GetCurrentUserProfile use case
          // yang mengambil data dari tabel 'profiles' kita.
          // Untuk sementara, kita coba buat UserProfile sederhana dari Supabase user.
          // Ini BUKAN data lengkap dari tabel 'profiles' kita.
          final profile = await _fetchUserProfileFromDb(user.id);
          if (profile != null) {
            emit(AuthAuthenticated(userProfile: profile));
          } else {
            // Jika profil tidak ditemukan di DB kita setelah login Supabase,
            // ini bisa jadi masalah sinkronisasi atau user baru yang profilnya belum dibuat oleh trigger.
            // Untuk sementara, anggap tidak terautentikasi di level aplikasi kita.
            // Atau bisa juga emit AuthFailure.
            emit(AuthUnauthenticated());
            // Atau bisa juga logout dari Supabase jika profil tidak ada
            // await _supabaseClient.auth.signOut();
          }
        } catch (e) {
          emit(AuthFailure(message: 'Gagal mengambil profil pengguna: ${e.toString()}'));
        }
      } else {
        // Pengguna tidak terautentikasi
        emit(AuthUnauthenticated());
      }
    });
  }

  // Placeholder untuk mengambil profil dari tabel 'profiles'
  // Ini seharusnya dilakukan oleh datasource dan repository
  Future<UserProfile?> _fetchUserProfileFromDb(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single(); // .single() akan error jika tidak ada atau lebih dari 1

        // Mapping manual dari Map ke UserProfile
        // Ini seharusnya ada di model atau mapper
        return UserProfile(
          id: response['id'] as String,
          email: response['email'] as String,
          fullName: response['full_name'] as String,
          role: _parseUserRole(response['role'] as String?),
          nim: response['nim'] as String?,
          major: response['major'] as String?,
          avatarUrl: response['avatar_url'] as String?,
          updatedAt: response['updated_at'] != null
              ? DateTime.parse(response['updated_at'] as String)
              : null,
        );
    } catch (e) {
      // Jika user baru saja sign up, trigger mungkin belum selesai membuat profil.
      // Atau jika ada error lain.
      print("Error fetching profile from DB: $e"); // Log error
      return null;
    }
  }

  UserRole _parseUserRole(String? roleString) {
    if (roleString == 'mahasiswa') return UserRole.mahasiswa;
    if (roleString == 'staff_dosen') return UserRole.staffDosen;
    return UserRole.unknown;
  }


  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    // `onAuthStateChange` akan menangani update state secara otomatis.
    // Kita bisa saja langsung memeriksa session saat ini, tapi listener lebih reaktif.
    final session = _supabaseClient.auth.currentSession;
    if (session?.user != null) {
      try {
        final profile = await _fetchUserProfileFromDb(session!.user.id);
        if (profile != null) {
          emit(AuthAuthenticated(userProfile: profile));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
         emit(AuthFailure(message: 'Gagal memeriksa status autentikasi: ${e.toString()}'));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loginUser(String email, String password) async {
    emit(AuthLoading());
    try {
      // Validasi email sesuai format Universitas Pertamina
      if (!RegExp(AppConstants.emailRegexPattern).hasMatch(email)) {
        emit(const AuthFailure(message: 'Format email tidak valid. Gunakan email Universitas Pertamina.'));
        return;
      }

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // `onAuthStateChange` akan menangani emisi state AuthAuthenticated
      // jika login Supabase berhasil dan profil ditemukan.
      // Jika login Supabase gagal, Supabase akan throw error.
      if (response.user == null) {
         emit(const AuthFailure(message: 'Login gagal. Periksa kembali email dan password Anda.'));
      }
      // Jika response.user ada, _monitorAuthState akan mengambil alih.

    } on supabase.AuthException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> logoutUser() async {
    emit(AuthLoading());
    try {
      await _supabaseClient.auth.signOut();
      // `onAuthStateChange` akan menangani emisi state AuthUnauthenticated.
    } on supabase.AuthException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  // Placeholder untuk update profil, akan menggunakan use case nanti
  Future<void> updateUserProfile(UserProfile updatedProfileData) async {
    if (state is AuthAuthenticated) {
      emit(AuthLoading()); // Atau state spesifik untuk updating profile
      try {
        // final currentUser = (state as AuthAuthenticated).userProfile;
        // Panggil UpdateUserProfile use case di sini
        // Untuk sementara, kita bisa langsung update ke Supabase (tidak ideal)
        // await _supabaseClient.from('profiles').update({
        //   'full_name': updatedProfileData.fullName,
        //   'major': updatedProfileData.major,
        //   // ... field lain yang bisa diupdate
        // }).eq('id', currentUser.id);

        // Setelah berhasil update, fetch ulang profil atau update state secara lokal
        // emit(AuthAuthenticated(userProfile: updatedProfileData.copyWith(updatedAt: DateTime.now())));
        
        // Untuk sekarang, kita asumsikan berhasil dan emit ulang state dengan data baru (dummy)
        // Idealnya, data baru ini didapat dari respons use case/repository
        emit(AuthAuthenticated(userProfile: updatedProfileData.copyWith(updatedAt: DateTime.now())));
         // Refresh data profil setelah update
        await checkAuthStatus();


      } catch (e) {
        emit(AuthFailure(message: "Gagal update profil: ${e.toString()}"));
        // Kembalikan ke state authenticated sebelumnya jika ada error
        // await checkAuthStatus(); // atau emit state sebelumnya
      }
    }
  }


  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
