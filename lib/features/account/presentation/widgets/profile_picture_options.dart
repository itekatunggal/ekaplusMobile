// lib/features/account/presentation/widgets/profile_picture_options_sheet.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/services/avatar_local_storage.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/adjust_profile_picture_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/profile_picture_viewer_page.dart';
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
  final BuildContext hostContext;

  const ProfilePictureOptionsSheet({
    super.key,
    required this.user,
    required this.onDismiss,
    required this.hostContext,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalAvatar = user.profilePic.startsWith('local:');
    final hasProfilePicture = user.profilePic.trim().isNotEmpty;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Foto Profil',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Atur foto yang tampil di akun Anda',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              _buildCurrentPictureCard(hasProfilePicture),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'GANTI FOTO',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.camera_alt_outlined,
                      label: 'Kamera',
                      iconColor: const Color(0xFFB91C1C),
                      iconBackground: const Color(0xFFFEE2E2),
                      onTap: () async {
                        final authBloc = hostContext.read<AuthBloc>();
                        final authSessionCubit = hostContext
                            .read<AuthSessionCubit>();
                        onDismiss();
                        await _pickImage(
                          source: ImageSource.camera,
                          authBloc: authBloc,
                          authSessionCubit: authSessionCubit,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.photo_library_outlined,
                      label: 'Galeri',
                      iconColor: const Color(0xFF1D4ED8),
                      iconBackground: const Color(0xFFDBEAFE),
                      onTap: () async {
                        final authBloc = hostContext.read<AuthBloc>();
                        final authSessionCubit = hostContext
                            .read<AuthSessionCubit>();
                        onDismiss();
                        await _pickImage(
                          source: ImageSource.gallery,
                          authBloc: authBloc,
                          authSessionCubit: authSessionCubit,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.face_outlined,
                      label: 'Avatar',
                      iconColor: const Color(0xFF7C3AED),
                      iconBackground: const Color(0xFFEDE9FE),
                      onTap: () {
                        onDismiss();
                        hostContext.pushNamed('selectAvatar', extra: user);
                      },
                    ),
                  ),
                ],
              ),
              if (hasLocalAvatar) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    onDismiss();
                    _deleteLocalAvatar(hostContext);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(
                    'Hapus avatar dan gunakan foto sebelumnya',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPictureCard(bool hasProfilePicture) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildProfilePreview(),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.trim().isEmpty ? 'Foto Anda' : user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasProfilePicture
                      ? 'Foto profil saat ini'
                      : 'Belum ada foto profil',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (hasProfilePicture) ...[
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                onDismiss();
                Navigator.of(hostContext, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => ProfilePictureViewerPage(user: user),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: Color(0xFFFECACA)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: Text(
                'Lihat',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfilePreview() {
    final value = user.profilePic.trim();
    Widget image;

    if (value.startsWith('local:')) {
      final parts = value.substring(6).split('|');
      final backgroundValue = parts.length > 1 ? int.tryParse(parts[1]) : null;
      image = ColoredBox(
        color: backgroundValue == null
            ? AppColors.primaryColor
            : Color(backgroundValue),
        child: Image.asset(
          parts.first,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildInitials(),
        ),
      );
    } else if (value.startsWith('assets/')) {
      image = Image.asset(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    } else if (value.isNotEmpty) {
      image = Image.network(
        value.startsWith('http')
            ? ApiConfig.addImageUpdatedAt(value)
            : ApiConfig.getImageUrl(value),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    } else {
      image = _buildInitials();
    }

    return Container(
      width: 60,
      height: 60,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: image,
    );
  }

  Widget _buildInitials() {
    final nameParts = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = nameParts.isEmpty
        ? 'ET'
        : nameParts.take(2).map((part) => part[0].toUpperCase()).join();

    return ColoredBox(
      color: AppColors.primaryColor,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.primaryFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage({
    required ImageSource source,
    required AuthBloc authBloc,
    required AuthSessionCubit authSessionCubit,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      if (!hostContext.mounted) return;
      final adjustedImagePath =
          await Navigator.of(hostContext, rootNavigator: true).push<String>(
            MaterialPageRoute(
              builder: (_) => AdjustProfilePicturePage(imagePath: image.path),
            ),
          );
      if (adjustedImagePath == null) return;

      authBloc.add(
        UpdateProfilePictureEvent(
          userId: user.phone,
          profilePicPath: adjustedImagePath,
        ),
      );

      final state = await authBloc.stream.firstWhere(
        (state) =>
            state is ProfilePictureUpdateSuccess ||
            state is ProfilePictureUpdateError,
      );

      if (state is ProfilePictureUpdateSuccess) {
        await authSessionCubit.updateUser(state.user);
        await AvatarLocalStorage.clearLocalAvatar();
        await AvatarLocalStorage.clearOriginalProfilePic();
        AppSnackbar.showGlobal(
          message: 'Foto profil berhasil diubah',
          type: AppSnackbarType.success,
        );
      } else if (state is ProfilePictureUpdateError) {
        AppSnackbar.showGlobal(
          message: 'Gagal mengubah foto profil: ${state.message}',
          type: AppSnackbarType.error,
        );
      }
    } catch (e) {
      AppSnackbar.showGlobal(
        message: 'Gagal mengambil foto: $e',
        type: AppSnackbarType.error,
      );
    }
  }

  Future<void> _deleteLocalAvatar(BuildContext context) async {
    // Save references BEFORE dialog
    final authSessionCubit = context.read<AuthSessionCubit>();

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
    if (!context.mounted) return;

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

        AppSnackbar.showGlobal(
          message: 'Avatar berhasil dihapus',
          type: AppSnackbarType.success,
        );
      } catch (e) {
        AppSnackbar.showGlobal(
          message: 'Gagal menghapus avatar: $e',
          type: AppSnackbarType.error,
        );
      }
    }
  }
}
