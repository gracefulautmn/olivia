import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:olivia/features/auth/domain/usecases/get_current_user.dart';
import 'package:olivia/features/auth/domain/usecases/login_user.dart';
import 'package:olivia/features/auth/domain/usecases/logout_user.dart';
// ===>>> IMPORT SignUpUser DAN SignUpParams <<<===
import 'package:olivia/features/auth/domain/usecases/signup_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  final SignUpUser _signUpUser; // Tambahkan _signUpUser
  final GetCurrentUser _getCurrentUser;
  final LogoutUser _logoutUser;
  final GetAuthStateChanges _getAuthStateChanges;
  StreamSubscription<UserProfile?>? _authStateChangesSubscription;

  AuthBloc({
    required LoginUser loginUser,
    required SignUpUser signUpUser, // Tambahkan di constructor
    required GetCurrentUser getCurrentUser,
    required LogoutUser logoutUser,
    required GetAuthStateChanges getAuthStateChanges,
  })  : _loginUser = loginUser,
        _signUpUser = signUpUser, // Inisialisasi
        _getCurrentUser = getCurrentUser,
        _logoutUser = logoutUser,
        _getAuthStateChanges = getAuthStateChanges,
        super(const AuthState.unknown()) {
    on<AuthCheckStatusRequested>(_onAuthCheckStatusRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested); // Tambahkan handler untuk AuthSignUpRequested
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);

    _authStateChangesSubscription = _getAuthStateChanges(
      NoParams(),
    ).listen((user) => add(AuthUserChanged(user)));
  }

  @override
  Future<void> close() {
    _authStateChangesSubscription?.cancel();
    return super.close();
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onAuthCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => user != null
          ? emit(AuthState.authenticated(user))
          : emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _loginUser(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthState.unauthenticated(failure: failure)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  // ===>>> HANDLER UNTUK AuthSignUpRequested <<<===
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading()); // Bisa juga state registering() jika ada
    final result = await _signUpUser(SignUpParams(
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword, // Dari event
      fullName: event.fullName, // Dari event
    ));
    result.fold(
      (failure) => emit(AuthState.unauthenticated(failure: failure)),
      (userProfile) {
        // Setelah sign up berhasil (dan jika konfirmasi email tidak diperlukan atau sudah otomatis),
        // anggap user langsung terautentikasi.
        // Jika konfirmasi email diperlukan, Anda mungkin ingin emit state lain
        // atau mengarahkan pengguna ke halaman "Cek Email".
        emit(AuthState.authenticated(userProfile));
      }
    );
  }
  // ===>>> AKHIR HANDLER <<<===

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _logoutUser(NoParams());
    result.fold(
      (failure) => emit(AuthState.unauthenticated(failure: failure)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }
}