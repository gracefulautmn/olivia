import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:olivia/common_widgets/custom_button.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/common_widgets/user_avatar.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile'; // Sesuai di AppRouter

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated ||
        authState.user == null) {
      // Seharusnya tidak terjadi karena ada redirect di GoRouter, tapi sebagai fallback
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(
          child: Text('Anda harus login untuk melihat profil.'),
        ),
      );
    }

    return BlocProvider(
      create:
          (context) => sl<ProfileBloc>(
            param1: context.read<AuthBloc>(),
          ) // Kirim AuthBloc jika diperlukan
          ..add(LoadUserProfile(userId: authState.user!.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Saya'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                // GoRouter akan handle redirect ke login page
              },
            ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.status == ProfileStatus.updateFailure &&
                state.failure != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gagal update profil: ${state.failure!.message}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
            }
            if (state.status == ProfileStatus.updateSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Profil berhasil diperbarui!'),
                    backgroundColor: Colors.green,
                  ),
                );
            }
          },
          builder: (context, state) {
            if (state.status == ProfileStatus.loading ||
                state.status == ProfileStatus.initial) {
              return const Center(child: LoadingIndicator());
            }
            if (state.status == ProfileStatus.failure &&
                state.userProfile == null) {
              // Gagal load profil awal
              return Center(
                child: ErrorDisplayWidget(
                  message: state.failure?.message ?? 'Gagal memuat profil.',
                  onRetry:
                      () => context.read<ProfileBloc>().add(
                        LoadUserProfile(userId: authState.user!.id),
                      ),
                ),
              );
            }
            if (state.userProfile != null) {
              return _buildProfileContent(context, state);
            }
            return const Center(child: Text('Tidak ada data profil.'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileState profileState) {
    final user = profileState.userProfile!;
    final bool isStudent = user.role == UserRole.mahasiswa;
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage(ImageSource source) async {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 400,
          imageQuality: 80,
          preferredCameraDevice:
              CameraDevice.front, // Lebih cocok untuk selfie avatar
        );
        if (pickedFile != null) {
          context.read<ProfileBloc>().add(
            ProfileAvatarChanged(File(pickedFile.path)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }

    void _showImageSourceActionSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Center(
          child: Stack(
            children: [
              UserAvatar(
                imageUrl:
                    profileState.newAvatarFile != null
                        ? null
                        : user.avatarUrl, // Prioritaskan newAvatarFile jika ada
                initialName: user.fullName,
                radius: 60,
                // Jika newAvatarFile ada, tampilkan dari file
                // Ini butuh modifikasi UserAvatar atau widget terpisah untuk File
              ),
              if (profileState.newAvatarFile != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(profileState.newAvatarFile!),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: AppColors.primaryColor,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _showImageSourceActionSheet(context),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            user.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Chip(
            label: Text(
              user.role == UserRole.mahasiswa
                  ? 'Mahasiswa'
                  : (user.role == UserRole.keamanan ? 'Keamanan' : 'Dosen/Staff'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor:
                user.role == UserRole.mahasiswa
                    ? AppColors.primaryColor
                    : AppColors.secondaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),

        _buildInfoRow(
          Icons.person_outline,
          'Nama Lengkap',
          user.fullName,
        ),
        
         if (isStudent)
          _buildInfoRow(
            Icons.school_outlined,
            'Jurusan',
            user.major ?? '-', // Menampilkan '-' jika major null
          ),
          
        if (user.nim != null && user.nim!.isNotEmpty)
          _buildInfoRow(Icons.badge_outlined, 'NIM/NIDN', user.nim!),

        const SizedBox(height: 30),
        CustomButton(
          text: 'Simpan Perubahan',
          isLoading: profileState.status == ProfileStatus.updating,
          onPressed: () {
            // Validasi form sebelum submit (jika ada GlobalKey<FormState>)
            // Untuk sekarang, langsung panggil event
            context.read<ProfileBloc>().add(
              UpdateProfileRequested(
                userId: user.id,
                fullName: profileState.currentFullName,
                major: isStudent ? profileState.currentMajor : null,
                // avatarFile sudah di state via ProfileAvatarChanged
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required BuildContext context,
    required String label,
    required String initialValue,
    required IconData icon,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
