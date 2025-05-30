part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile? user;
  final Failure? failure; // Untuk menangani error saat login/logout

  const AuthState._({
    required this.status,
    this.user,
    this.failure,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);
  const AuthState.loading() : this._(status: AuthStatus.loading, user: null, failure: null); // Reset user dan failure saat loading
  const AuthState.authenticated(UserProfile user) : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated({Failure? failure}) : this._(status: AuthStatus.unauthenticated, failure: failure);

  @override
  List<Object?> get props => [status, user, failure];
}