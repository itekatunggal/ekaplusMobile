// lib/features/account/presentation/widgets/profile_picture_options_sheet.dart
// ignore_for_file: use_build_context_synchronously

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/services/avatar_local_storage.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureOptionsSheet extends StatelessWidget {
  final User user;
  final VoidCallback onDismiss;

  const ProfilePictureOptionsSheet({
    super.key,
    required this.user,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalAvatar = user.profilePic.startsWith('local:');

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 188, 11, 11),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pilih Foto Profil',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Perbarui tampilan identitas anda',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOption(
                context,
                icon: Icons.camera_alt,
                title: 'Ambil Foto',
                subtitle: 'Gunakan kamera langsung',
                onTap: () async {
                  onDismiss();
                  await _pickImageFromCamera(context);
                },
              ),
              const Divider(height: 1),
              _buildOption(
                context,
                icon: Icons.photo_library,
                title: 'Ambil dari Galeri',
                subtitle: 'Pilih dari penyimpanan',
                onTap: () async {
                  onDismiss();
                  await _pickImageFromGallery(context);
                },
              ),
              const Divider(height: 1),
              _buildOption(
                context,
                icon: Icons.face,
                title: 'Ubah Avatar',
                subtitle: 'Pilih ilustrasi karakter',
                onTap: () {
                  onDismiss();
                  context.pushNamed('selectAvatar', extra: user);
                },
              ),
              if (hasLocalAvatar) ...[
                const Divider(height: 1),
                _buildOption(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Hapus Avatar',
                  subtitle: 'Kembali ke foto profil sebelumnya',
                  color: Colors.red,
                  onTap: () {
                    onDismiss();
                    _deleteLocalAvatar(context);
                  },
                ),
              ],
              const Divider(height: 1),
              _buildOption(
                context,
                icon: Icons.close,
                title: 'Batalkan',
                onTap: onDismiss,
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    // Save references BEFORE async operations
    final authBloc = context.read<AuthBloc>();
    final authSessionCubit = context.read<AuthSessionCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final imagePath = image.path;

        // Clear local avatar karena user mau upload foto baru
        await AvatarLocalStorage.clearLocalAvatar();
        await AvatarLocalStorage.clearOriginalProfilePic();

        // Update via AuthBloc
        authBloc.add(
          UpdateProfilePictureEvent(
            userId: user.phone,
            profilePicPath: imagePath,
          ),
        );

        // Wait for result using stream.firstWhere
        await authBloc.stream
            .firstWhere(
              (state) =>
                  state is ProfilePictureUpdateSuccess ||
                  state is ProfilePictureUpdateError,
            )
            .then((state) async {
              if (state is ProfilePictureUpdateSuccess) {
                // Update session dengan user yang baru
                await authSessionCubit.updateUser(state.user);

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Foto profil berhasil diubah',
                      style: TextStyle(fontFamily: AppFonts.primaryFont),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ProfilePictureUpdateError) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gagal mengubah foto profil: ${state.message}',
                      style: TextStyle(fontFamily: AppFonts.primaryFont),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil foto: $e',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    // Save references BEFORE async operations
    final authBloc = context.read<AuthBloc>();
    final authSessionCubit = context.read<AuthSessionCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final imagePath = image.path;

        // Clear local avatar karena user mau upload foto baru
        await AvatarLocalStorage.clearLocalAvatar();
        await AvatarLocalStorage.clearOriginalProfilePic();

        // Update via AuthBloc
        authBloc.add(
          UpdateProfilePictureEvent(
            userId: user.phone,
            profilePicPath: imagePath,
          ),
        );

        // Wait for result using stream.firstWhere
        await authBloc.stream
            .firstWhere(
              (state) =>
                  state is ProfilePictureUpdateSuccess ||
                  state is ProfilePictureUpdateError,
            )
            .then((state) async {
              if (state is ProfilePictureUpdateSuccess) {
                // Update session dengan user yang baru
                await authSessionCubit.updateUser(state.user);

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Foto profil berhasil diubah',
                      style: TextStyle(fontFamily: AppFonts.primaryFont),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ProfilePictureUpdateError) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gagal mengubah foto profil: ${state.message}',
                      style: TextStyle(fontFamily: AppFonts.primaryFont),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil foto: $e',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteLocalAvatar(BuildContext context) async {
    // Save references BEFORE dialog
    final authSessionCubit = context.read<AuthSessionCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hapus Avatar',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Avatar akan dihapus dan kembali ke foto profil sebelumnya',
          style: TextStyle(fontFamily: AppFonts.primaryFont),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Hapus',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Get original profile pic
        final originalProfilePic =
            await AvatarLocalStorage.getOriginalProfilePic();

        // Clear local avatar
        await AvatarLocalStorage.clearLocalAvatar();
        await AvatarLocalStorage.clearOriginalProfilePic();

        // Restore ke foto profil sebelumnya (atau empty string jika tidak ada)
        final updatedUser = user.copyWith(profilePic: originalProfilePic ?? '');
        await authSessionCubit.updateUser(updatedUser);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Avatar berhasil dihapus',
              style: TextStyle(fontFamily: AppFonts.primaryFont),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus avatar: $e',
              style: TextStyle(fontFamily: AppFonts.primaryFont),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
