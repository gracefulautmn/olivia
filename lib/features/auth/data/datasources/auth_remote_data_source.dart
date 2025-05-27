import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/utils/constants.dart';
import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<UserProfileModel> loginUser({
    required String email,
    required String password,
  });
  Future<UserProfileModel?> getCurrentUser();
  Stream<UserProfileModel?> get authStateChanges;
  Future<void> logoutUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

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
        throw AuthException(message: 'Login failed: User not found.');
      }

      // Ambil data profil dari tabel 'profiles'
      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single(); // Mengharapkan satu baris data

      return UserProfileModel.fromJson(profileResponse);
    } on AuthException catch (e) {
      // Tangani error spesifik dari Supabase Auth
      throw AuthException(message: e.message);
    } catch (e) {
      // Tangani error umum
      throw ServerException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel?> getCurrentUser() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return null;
      }
      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle(); // Menggunakan maybeSingle karena bisa jadi profil belum ada

      if (profileResponse == null) return null;
      return UserProfileModel.fromJson(profileResponse);
    } catch (e) {
      throw ServerException(message: 'Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Stream<UserProfileModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user != null) {
        try {
          final profileResponse = await supabaseClient
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();
          return UserProfileModel.fromJson(profileResponse);
        } catch (e) {
          // Jika gagal fetch profile, anggap tidak login atau ada masalah
          print('Error fetching profile on auth state change: $e');
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
    } catch (e) {
      throw ServerException(message: 'Logout failed: ${e.toString()}');
    }
  }
}