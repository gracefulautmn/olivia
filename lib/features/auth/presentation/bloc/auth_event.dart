part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

// Event ini sekarang publik, sebelumnya _AuthUserChanged
// Digunakan untuk update dari stream auth state changes atau ketika profil user diupdate dari ProfileBloc
class AuthUserChanged extends AuthEvent {
  final UserProfile? user; // UserProfile bisa null jika user logout
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, confirmPassword, fullName];
}