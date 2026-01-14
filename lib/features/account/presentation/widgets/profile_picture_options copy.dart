// lib/features/account/presentation/widgets/profile_picture_options_sheet.dart
// ignore_for_file: use_build_context_synchronously

import 'package:ekaplus_ekatunggal/constant.dart';
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
    final hasProfilePic = user.profilePic.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          _buildOption(
            context,
            icon: Icons.photo_library,
            title: 'Ambil dari Galeri',
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
            onTap: () {
              onDismiss();
              context.pushNamed('selectAvatar', extra: user);
            },
          ),
          if (hasProfilePic) ...[
            const Divider(height: 1),
            _buildOption(
              context,
              icon: Icons.delete_outline,
              title: 'Hapus Avatar',
              color: Colors.red,
              onTap: () {
                onDismiss();
                _deleteProfilePicture(context);
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
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
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

        // Update via AuthBloc
        authBloc.add(
          UpdateProfilePictureEvent(
            userId: user.phone,
            profilePicPath: imagePath,
          ),
        );

        // Listen to result
        authBloc.stream.listen((state) {
          if (state is ProfilePictureUpdateSuccess) {
            authSessionCubit.updateUser(state.user);

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Foto profil berhasil diubah',
                  style: TextStyle(fontFamily: AppFonts.primaryFont),
                ),
                backgroundColor: Colors.green,
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

  Future<void> _deleteProfilePicture(BuildContext context) async {
    // Save references BEFORE dialog
    final authBloc = context.read<AuthBloc>();
    final authSessionCubit = context.read<AuthSessionCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hapus Foto Profil',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus foto profil?',
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
      // Update profile pic to null using saved references
      authBloc.add(
        UpdateProfilePictureEvent(userId: user.phone, profilePicPath: ""),
      );

      // Listen to result
      authBloc.stream.listen((state) {
        if (state is ProfilePictureUpdateSuccess) {
          authSessionCubit.updateUser(state.user);

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Foto profil berhasil dihapus',
                style: TextStyle(fontFamily: AppFonts.primaryFont),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }
}
