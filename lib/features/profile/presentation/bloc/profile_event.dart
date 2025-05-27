part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  final String userId;
  const LoadUserProfile({required this.userId});
   @override
  List<Object?> get props => [userId];
}

// Event untuk trigger update
class UpdateProfileRequested extends ProfileEvent {
  final String userId;
  final String? fullName;
  final String? major;
  final File? avatarFile;

  const UpdateProfileRequested({
    required this.userId,
    this.fullName,
    this.major,
    this.avatarFile,
  });
   @override
  List<Object?> get props => [userId, fullName, major, avatarFile];
}

// Event jika user memilih gambar baru
class ProfileAvatarChanged extends ProfileEvent {
  final File avatarFile;
  const ProfileAvatarChanged(this.avatarFile);
   @override
  List<Object?> get props => [avatarFile];
}

class ProfileFullNameChanged extends ProfileEvent {
  final String fullName;
  const ProfileFullNameChanged(this.fullName);
   @override
  List<Object?> get props => [fullName];
}

class ProfileMajorChanged extends ProfileEvent {
  final String major;
  const ProfileMajorChanged(this.major);
   @override
  List<Object?> get props => [major];
}