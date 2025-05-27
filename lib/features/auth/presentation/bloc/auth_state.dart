part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile? user;
  final Failure? failure;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.failure,
  });

  const AuthState.unknown() : this._();
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated(UserProfile user) : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated({Failure? failure}) : this._(status: AuthStatus.unauthenticated, failure: failure);


  @override
  List<Object?> get props => [status, user, failure];
}