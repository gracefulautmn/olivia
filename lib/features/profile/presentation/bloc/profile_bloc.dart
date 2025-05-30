import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
// Pastikan AuthUserChanged (event publik) dapat diakses.
// Import auth_bloc.dart seharusnya sudah cukup jika AuthUserChanged diekspor atau
// merupakan bagian dari library yang sama dan auth_event.dart adalah 'part of' auth_bloc.dart.
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart'; 
import 'package:olivia/features/profile/domain/usecases/get_user_profile.dart';
import 'package:olivia/features/profile/domain/usecases/update_user_profile.dart';

part 'profile_event.dart'; // Asumsikan file ini ada dan benar
part 'profile_state.dart'; // Asumsikan file ini ada dan benar

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final AuthBloc _authBloc;

  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required AuthBloc authBloc,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        _authBloc = authBloc,
        super(const ProfileState()) { // Pastikan ProfileState punya constructor default
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ProfileAvatarChanged>(_onProfileAvatarChanged);
    on<ProfileFullNameChanged>(_onProfileFullNameChanged);
    on<ProfileMajorChanged>(_onProfileMajorChanged);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearFailure: true));
    final result = await _getUserProfile(
      GetUserProfileParams(userId: event.userId),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(status: ProfileStatus.failure, failure: failure)),
      (profile) => emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          userProfile: profile,
          currentFullName: profile.fullName,
          currentMajor: profile.major ?? '',
        ),
      ),
    );
  }

  void _onProfileAvatarChanged(
    ProfileAvatarChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(newAvatarFile: event.avatarFile));
  }

  void _onProfileFullNameChanged(
    ProfileFullNameChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(currentFullName: event.fullName));
  }

  void _onProfileMajorChanged(
    ProfileMajorChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(currentMajor: event.major));
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    bool hasChanges = false;
    if (state.newAvatarFile != null) hasChanges = true;
    if (event.fullName != null && event.fullName != state.userProfile?.fullName) {
      hasChanges = true;
    }
    if (event.major != null && event.major != state.userProfile?.major) {
      hasChanges = true;
    }

    if (!hasChanges && state.newAvatarFile == null) {
      emit(
        state.copyWith(status: ProfileStatus.loaded),
      ); 
      return;
    }

    final params = UpdateUserProfileParams(
      userId: event.userId, // Pastikan event.userId selalu ada dan benar
      fullName: event.fullName,
      major: event.major,
      avatarFile: state.newAvatarFile,
    );

    final result = await _updateUserProfile(params);

    result.fold(
      (failure) => emit(
        state.copyWith(status: ProfileStatus.updateFailure, failure: failure),
      ),
      (updatedProfile) {
        emit(
          state.copyWith(
            status: ProfileStatus.updateSuccess,
            userProfile: updatedProfile,
            currentFullName: updatedProfile.fullName,
            currentMajor: updatedProfile.major ?? '',
            clearNewAvatarFile: true, 
          ),
        );
        
        // Jika user yang diupdate adalah user yang sedang login, update juga state di AuthBloc
        // Menggunakan event publik AuthUserChanged
        if (_authBloc.state.user?.id == updatedProfile.id) {
          _authBloc.add(
            AuthUserChanged(updatedProfile), // << PERBAIKAN DI SINI
          ); 
        }
      },
    );
  }
}