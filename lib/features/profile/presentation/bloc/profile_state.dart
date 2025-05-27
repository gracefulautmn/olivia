part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, updating, updateSuccess, updateFailure, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? userProfile;
  final Failure? failure;

  // Untuk form edit
  final File? newAvatarFile;
  final String currentFullName;
  final String currentMajor;


  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userProfile,
    this.failure,
    this.newAvatarFile,
    this.currentFullName = '',
    this.currentMajor = '',
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? userProfile,
    Failure? failure,
    bool clearFailure = false,
    File? newAvatarFile,
    bool clearNewAvatarFile = false,
    String? currentFullName,
    String? currentMajor,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userProfile: userProfile ?? this.userProfile,
      failure: clearFailure ? null : failure ?? this.failure,
      newAvatarFile: clearNewAvatarFile ? null : newAvatarFile ?? this.newAvatarFile,
      currentFullName: currentFullName ?? this.currentFullName,
      currentMajor: currentMajor ?? this.currentMajor,
    );
  }

  @override
  List<Object?> get props => [status, userProfile, failure, newAvatarFile, currentFullName, currentMajor];
}