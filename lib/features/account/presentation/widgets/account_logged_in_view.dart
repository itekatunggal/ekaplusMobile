import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/whatsapp_helper.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/profile_picture_options.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountLoggedInView extends StatelessWidget {
  const AccountLoggedInView({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, state) {
        final currentUser = state is AuthSessionAuthenticated
            ? state.user
            : user;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
              child: Column(
                children: [
                  _ProfileCard(
                    user: currentUser,
                    onEdit: () => context.pushNamed('edit-profile'),
                    onPhotoTap: () =>
                        _showProfilePictureOptions(context, currentUser),
                  ),
                  const SizedBox(height: 14),
                  _AccountSection(
                    title: 'Preferensi Akun',
                    children: [
                      _AccountMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi Aplikasi',
                        subtitle: 'Promo, pesanan, dan pembaruan',
                        onTap: () =>
                            _comingSoon(context, 'Pengaturan notifikasi'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _AccountSection(
                    title: 'Pengaturan & Keamanan Akun',
                    children: [
                      _AccountMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Data Diri / Ubah Profil',
                        subtitle: 'Nama, email, username & keamanan',
                        onTap: () => context.pushNamed('edit-profile'),
                      ),
                      _AccountMenuItem(
                        icon: Icons.fingerprint_rounded,
                        title: 'Keamanan Biometrik',
                        badge: 'Segera',
                        onTap: () => _comingSoon(context, 'Keamanan biometrik'),
                      ),
                      _AccountMenuItem(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.primaryColor,
                        iconBackground: const Color(0xFFFFF1F2),
                        title: 'Keluar dari Akun',
                        titleColor: AppColors.primaryColor,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _AccountSection(
                    title: 'Pusat Informasi & Bantuan',
                    children: [
                      _AccountMenuItem(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.primaryColor,
                        iconBackground: const Color(0xFFFFF1F2),
                        title: 'Tentang Ekatunggal',
                        onTap: () => context.pushNamed('about'),
                      ),
                      _AccountMenuItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: const Color(0xFF128C7E),
                        iconBackground: const Color(0xFFDCFCE7),
                        title: 'Tanya Vika',
                        subtitle: 'Bantuan cepat via WhatsApp',
                        badge: 'CS Online',
                        onTap: () => WhatsAppHelper.openGeneral(context),
                      ),
                      _AccountMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Pertanyaan Umum (FAQ)',
                        onTap: () => _comingSoon(context, 'FAQ'),
                      ),
                      _AccountMenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Syarat & Kebijakan Privasi',
                        onTap: () =>
                            _comingSoon(context, 'Syarat & Kebijakan Privasi'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Ekatunggal Mobile App',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfilePictureOptions(BuildContext context, User currentUser) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ProfilePictureOptionsSheet(
        user: currentUser,
        onDismiss: () => Navigator.pop(sheetContext),
      ),
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    AppSnackbar.show(
      context,
      message: '$feature akan segera tersedia',
      type: AppSnackbarType.info,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Anda perlu masuk kembali untuk mengakses data akun.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ActiveCompanyCubit>().reset();
              context.read<AuthSessionCubit>().logout();
              context.goNamed('home');
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.onEdit,
    required this.onPhotoTap,
  });
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: accountCardDecoration,
      child: Row(
        children: [
          AccountAvatar(
            user: user,
            size: 62,
            onTap: onPhotoTap,
            showCamera: true,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName.isEmpty
                            ? 'Pengguna Ekatunggal'
                            : user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (user.isEmailVerified || user.isPhoneVerified) ...[
                      const SizedBox(width: 6),
                      const AccountStatusBadge(label: 'Terverifikasi'),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        user.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onEdit,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryColor,
                    size: 19,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ubah',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: accountCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 8),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index != children.length - 1)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF1F5F9),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.iconColor = const Color(0xFF475569),
    this.iconBackground = const Color(0xFFF1F5F9),
    this.titleColor = const Color(0xFF1E293B),
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color iconColor;
  final Color iconBackground;
  final Color titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 7),
                        AccountStatusBadge(label: badge!),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountStatusBadge extends StatelessWidget {
  const AccountStatusBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFECFDF5),
      border: Border.all(color: const Color(0xFFA7F3D0)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFF059669),
        fontSize: 8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

const accountCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [
    BoxShadow(color: Color(0x0D0F172A), blurRadius: 10, offset: Offset(0, 2)),
  ],
);

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.user,
    required this.size,
    this.onTap,
    this.showCamera = false,
  });
  final User user;
  final double size;
  final VoidCallback? onTap;
  final bool showCamera;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFECACA), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: _image(),
          ),
          if (showCamera)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * .34,
                height: size * .34,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: size * .17,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _image() {
    final value = user.profilePic.trim();
    if (value.startsWith('local:')) {
      final parts = value.substring(6).split('|');
      if (parts.isNotEmpty) {
        final color = parts.length > 1 ? int.tryParse(parts[1]) : null;
        return ColoredBox(
          color: color == null ? AppColors.primaryColor : Color(color),
          child: Image.asset(
            parts.first,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        );
      }
    }
    if (value.startsWith('assets/')) {
      return Image.asset(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (value.isNotEmpty) {
      final url = value.startsWith('http')
          ? value
          : '${ApiConfig.baseImageUrl}/$value';
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final parts = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? 'ET'
        : parts.take(2).map((part) => part[0].toUpperCase()).join();
    return ColoredBox(
      color: AppColors.primaryColor,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * .3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
