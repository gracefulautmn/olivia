// lib/features/auth/presentation/cubit_or_bloc/auth_state.dart

part of 'auth_cubit.dart'; // Akan kita buat AuthCubit di file terpisah

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// State awal, sebelum ada pengecekan status autentikasi
class AuthInitial extends AuthState {}

// State ketika sedang proses loading (misal: login, logout, cek status)
class AuthLoading extends AuthState {}

// State ketika pengguna berhasil terautentikasi
class AuthAuthenticated extends AuthState {
  final UserProfile userProfile; // Informasi profil pengguna yang login

  const AuthAuthenticated({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

// State ketika pengguna tidak terautentikasi atau sudah logout
class AuthUnauthenticated extends AuthState {}

// State ketika terjadi error selama proses autentikasi
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
