import 'package:olivia/core/errors/exceptions.dart' as core_exceptions; // Awalan untuk custom exceptions Anda
import 'package:olivia/core/utils/constants.dart';
import 'package:olivia/features/auth/data/models/user_profile_model.dart';
// ===>>> GANTI CARA IMPORT SUPABASE <<<===
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // Beri alias 'supabase'

abstract class AuthRemoteDataSource {
  Future<UserProfileModel> loginUser({
    required String email,
    required String password,
  });
  Future<UserProfileModel?> getCurrentUser();
  Stream<UserProfileModel?> get authStateChanges;
  Future<void> logoutUser();
  Future<UserProfileModel> signUpUser({
    required String email,
    required String password,
    required String fullName,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // ===>>> GUNAKAN TIPE DENGAN ALIAS <<<===
  final supabase.SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserProfileModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw core_exceptions.AuthException(message: 'Login failed: User not found by Supabase.');
      }

      final profileResponseData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single(); // Mengharapkan satu baris

      return UserProfileModel.fromJson(profileResponseData);

    } on supabase.AuthException catch (e) { // ===>>> TANGKAP supabase.AuthException <<<===
      print('Supabase AuthException on login: ${e.message}');
      // Pesan dari Supabase untuk invalid credentials biasanya sudah cukup jelas
      throw core_exceptions.AuthException(message: e.message);
    } on supabase.PostgrestException catch (e) {
       print("Supabase Postgrest error in loginUser (profile fetch): ${e.message}");
       // Ini bisa terjadi jika profil tidak ditemukan setelah login (seharusnya tidak jika trigger benar)
       if (e.code == 'PGRST116') { // Not found
            throw core_exceptions.ServerException(message: "Profil pengguna tidak ditemukan setelah login.");
       }
       throw core_exceptions.ServerException(message: "Gagal mengambil profil setelah login: ${e.message}");
    } catch (e) {
      print("General error in loginUser: $e");
      // Hindari melempar kembali error yang sudah ditangani, hanya lempar jika belum
      if (e is! core_exceptions.AuthException && e is! core_exceptions.ServerException) {
        throw core_exceptions.ServerException(message: 'Login gagal karena kesalahan tak terduga: ${e.toString()}');
      }
      rethrow; // Lempar kembali jika sudah tipe yang benar
    }
  }

  @override
  Future<UserProfileModel?> getCurrentUser() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return null;
      }
      final profileResponseData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle(); // Menggunakan maybeSingle karena bisa jadi profil belum ada

      if (profileResponseData == null) return null;
      return UserProfileModel.fromJson(profileResponseData);

    } on supabase.PostgrestException catch (e) {
        print("Supabase Postgrest error in getCurrentUser: ${e.message}");
        throw core_exceptions.ServerException(message: 'Gagal mengambil data pengguna saat ini: ${e.message}');
    } catch (e) {
      print("General error in getCurrentUser: $e");
      throw core_exceptions.ServerException(message: 'Gagal mengambil data pengguna saat ini: ${e.toString()}');
    }
  }

  @override
  Stream<UserProfileModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user != null) {
        try {
          // Menggunakan maybeSingle untuk lebih aman jika profil belum siap
          final profileResponseData = await supabaseClient
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (profileResponseData == null) {
            print('Profile not found for user ${user.id} during auth state change. Trigger might be pending or email confirmation needed.');
            return null;
          }
          return UserProfileModel.fromJson(profileResponseData);
        } on supabase.PostgrestException catch (e) {
          print('Error fetching profile on auth state change (Postgrest): ${e.message}');
          return null; // Jika ada error database saat fetch, anggap profil belum siap
        } catch (e) {
          print('Error fetching profile on auth state change (General): $e');
          return null;
        }
      }
      return null;
    });
  }


  @override
  Future<void> logoutUser() async {
    try {
      await supabaseClient.auth.signOut();
    } on supabase.AuthException catch (e) { // ===>>> TANGKAP supabase.AuthException <<<===
      print("Supabase Auth error during logout: ${e.message}");
      throw core_exceptions.AuthException(message: 'Logout gagal: ${e.message}');
    } catch (e) {
      print("General error during logout: $e");
      throw core_exceptions.ServerException(message: 'Logout gagal: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel> signUpUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final Map<String, dynamic> metaData = {'full_name': fullName};

      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: metaData,
      );

      if (authResponse.user == null) {
        // Ini bisa terjadi jika auto-confirm OFF dan Supabase menganggap proses belum selesai
        // atau jika ada error jaringan sebelum respons lengkap diterima.
        throw core_exceptions.AuthException(message: 'Proses pendaftaran tidak mengembalikan informasi pengguna. Periksa email Anda untuk konfirmasi jika diaktifkan.');
      }
      
      // Coba fetch profil setelah sign up menggunakan maybeSingle untuk mengatasi potensi delay trigger
      final Map<String, dynamic>? profileResponseData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      if (profileResponseData == null) {
        // Jika profil tidak ditemukan, ini bisa jadi karena delay trigger,
        // atau trigger gagal (seharusnya signUp juga gagal jika trigger error),
        // atau user perlu konfirmasi email.
        print('Profil tidak ditemukan segera setelah pendaftaran untuk user ID: ${authResponse.user!.id}. Kemungkinan delay pada trigger atau perlu konfirmasi email.');
        // Di sini kita melempar ServerException karena signUp di auth berhasil, tapi data pendukung (profil) belum siap.
        // Aplikasi mungkin perlu mengarahkan user untuk cek email atau mencoba login nanti.
        throw core_exceptions.ServerException(message: "Pendaftaran berhasil, namun profil pengguna belum dapat dimuat. Mungkin perlu konfirmasi email atau coba login kembali.");
      }

      return UserProfileModel.fromJson(profileResponseData);

    } on supabase.AuthException catch (e) { // ===>>> TANGKAP supabase.AuthException <<<===
      print('Supabase AuthException on signUp: ${e.message}');
      if (e.message.toLowerCase().contains('user already registered')) {
         throw core_exceptions.AuthException(message: 'Email sudah terdaftar. Silakan gunakan email lain atau login.');
      }
      // Untuk error auth lain dari Supabase, teruskan pesannya.
      throw core_exceptions.AuthException(message: e.message);
    } on supabase.PostgrestException catch (e) {
      // Error ini seharusnya tidak terjadi jika logic di atas untuk profileResponseData null sudah benar,
      // tapi sebagai fallback.
      print('Supabase PostgrestException on signUp (profile fetch): ${e.message}');
      throw core_exceptions.ServerException(message: "Pendaftaran berhasil, namun terjadi kesalahan saat mengambil detail profil: ${e.message}.");
    } catch (e) {
      print('General error on signUp: $e');
      throw core_exceptions.ServerException(message: 'Pendaftaran gagal karena kesalahan tak terduga: ${e.toString()}');
    }
  }
}