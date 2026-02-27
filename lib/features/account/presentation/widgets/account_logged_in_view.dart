// lib/features/account/presentation/widgets/account_logged_in_view.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/profile_picture_options.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_member_registrations_by_user_id.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_active_member_companies_by_user_id.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountLoggedInView extends StatefulWidget {
  final User user;

  const AccountLoggedInView({super.key, required this.user});

  @override
  State<AccountLoggedInView> createState() => _AccountLoggedInViewState();
}

class _AccountLoggedInViewState extends State<AccountLoggedInView> {
  final GetMemberRegistrationsByUserId _getMemberRegistrationsByUserId =
      myinjection<GetMemberRegistrationsByUserId>();
  final GetActiveMemberCompaniesByUserId _getActiveMemberCompaniesByUserId =
      myinjection<GetActiveMemberCompaniesByUserId>();
  MemberRegistration? _latestRegistration;
  bool _isLoadingRegistration = true;
  String? _activeBcName;
  bool _isLoadingBcName = true;

  @override
  void initState() {
    super.initState();
    _loadMemberRegistration();
    _loadActiveCompanyName();
  }

  Future<void> _loadMemberRegistration() async {
    if (!mounted) return;
    setState(() => _isLoadingRegistration = true);

    final result = await _getMemberRegistrationsByUserId.execute();

    if (!mounted) return;

    result.fold(
      (failure) {
        if (!mounted) return;
        setState(() {
          _latestRegistration = null;
          _isLoadingRegistration = false;
        });
      },
      (registrations) {
        if (!mounted) return;
        final latest = registrations.isNotEmpty ? registrations.last : null;
        setState(() {
          _latestRegistration = latest;
          _isLoadingRegistration = false;
        });
      },
    );
  }

  Future<void> _loadActiveCompanyName() async {
    if (!mounted) return;
    setState(() => _isLoadingBcName = true);

    final result = await _getActiveMemberCompaniesByUserId.execute();
    if (!mounted) return;

    result.fold(
      (_) {
        setState(() {
          _activeBcName = null;
          _isLoadingBcName = false;
        });
      },
      (companies) {
        setState(() {
          _activeBcName = companies.isNotEmpty ? companies.first.displayName : null;
          _isLoadingBcName = false;
        });
      },
    );
  }

  double _getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return desktop;
    if (width >= 600) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, sessionState) {
        final currentUser = sessionState is AuthSessionAuthenticated
            ? sessionState.user
            : widget.user;

        return Container(
          width: double.infinity,
          color: AppColors.whiteColor,
          child: Column(
            children: [
              // Content with responsive padding
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    // Profile Avatar & Name
                    _buildProfileHeader(context, currentUser),

                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                    ),

                    // Email Verification Warning Banner
                    if (!currentUser.isEmailVerified) ...[
                      _buildEmailVerificationBanner(context, currentUser),
                      const SizedBox(height: 14),
                    ],

                    // Nama Lengkap
                    _buildInfoSection(
                      label: 'Nama Lengkap',
                      value: currentUser.fullName,
                      context: context,
                      userId: currentUser.phone,
                    ),

                    const Divider(height: 1),

                    const SizedBox(height: 10),

                    // Nomor Handphone
                    _buildInfoSection(
                      label: 'Nomor Handphone',
                      value: currentUser.phone,
                      context: context,
                      userId: currentUser.phone,
                    ),

                    const Divider(height: 1),

                    const SizedBox(height: 10),

                    // Email
                    _buildInfoSection(
                      label: 'Email',
                      value: currentUser.email,
                      context: context,
                      userId: currentUser.phone,
                    ),

                    const Divider(height: 1),
                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                    ),

                    _buildCompanyCard(context),
                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 14,
                        tablet: 18,
                        desktop: 22,
                      ),
                    ),

                    _buildDynamicCompanyButton(context, currentUser),
                  ],
                ),
              ),

              // Full width divider
              Container(
                width: double.infinity,
                height: _getResponsiveValue(
                  context,
                  mobile: 4,
                  tablet: 5,
                  desktop: 6,
                ),
                color: const Color(0xFFE0E0E0),
              ),

              // Settings Section
              _buildSettingsSection(context, currentUser),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User currentUser) {
    final avatarSize = _getResponsiveValue(
      context,
      mobile: 120.0,
      tablet: 150.0,
      desktop: 180.0,
    );

    final cameraIconSize = _getResponsiveValue(
      context,
      mobile: 38.0,
      tablet: 44.0,
      desktop: 50.0,
    );

    final nameTextSize = _getResponsiveValue(
      context,
      mobile: 15.0,
      tablet: 17.0,
      desktop: 19.0,
    );

    final statusTextSize = _getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 11.0,
      desktop: 12.0,
    );

    return Column(
      children: [
        // Avatar with camera icon
        Stack(
          children: [
            // Profile Picture
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: GestureDetector(
                onTap: () => _showProfilePictureOptions(context, currentUser),
                child: ClipOval(child: _buildProfileImage(currentUser)),
              ),
            ),

            // Camera Icon Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showProfilePictureOptions(context, currentUser),
                child: Container(
                  width: cameraIconSize,
                  height: cameraIconSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: cameraIconSize * 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Name
        Text(
          currentUser.fullName,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: nameTextSize,
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: _getResponsiveValue(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            vertical: _getResponsiveValue(
              context,
              mobile: 5,
              tablet: 6,
              desktop: 7,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x65A7A7A7), width: 1),
            color: const Color(0x33A7A7A7),
          ),
          child: Text(
            _isLoadingBcName
                ? 'Memuat perusahaan...'
                : (_activeBcName?.isNotEmpty == true
                      ? _activeBcName!
                      : 'Belum terhubung dengan perusahaan'),
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: statusTextSize,
              color: AppColors.blackColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationBanner(BuildContext context, User currentUser) {
    final iconSize = _getResponsiveValue(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
    );
    final titleSize = _getResponsiveValue(
      context,
      mobile: 11,
      tablet: 12,
      desktop: 13,
    );
    final subtitleSize = _getResponsiveValue(
      context,
      mobile: 9.5,
      tablet: 10.5,
      desktop: 11.5,
    );
    final buttonTextSize = _getResponsiveValue(
      context,
      mobile: 10.5,
      tablet: 11.5,
      desktop: 12.5,
    );

    return Container(
      padding: EdgeInsets.all(
        _getResponsiveValue(context, mobile: 9, tablet: 11, desktop: 13),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE69C), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFF57C00),
            size: iconSize,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Belum Terverifikasi',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF664D03),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verifikasi email Anda untuk mengakses semua fitur',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: subtitleSize,
                    color: const Color(0xFF664D03),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          TextButton(
            onPressed: () {
              context.pushNamed(
                'verify-email-initial',
                extra: {
                  'userId': currentUser.phone,
                  'email': currentUser.email,
                },
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsiveValue(
                  context,
                  mobile: 9,
                  tablet: 11,
                  desktop: 13,
                ),
                vertical: _getResponsiveValue(
                  context,
                  mobile: 5,
                  tablet: 6,
                  desktop: 7,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Verifikasi',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: buttonTextSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(User currentUser) {
    final String profilePic = (currentUser.profilePic.isNotEmpty)
        ? currentUser.profilePic
        : "";

    if (profilePic.isNotEmpty) {
      // Check if it's a local avatar (format: "local:avatarPath|bgColor")
      if (profilePic.startsWith('local:')) {
        final parts = profilePic.substring(6).split('|');
        if (parts.length == 2) {
          final avatarPath = parts[0];
          final bgColorValue = int.tryParse(parts[1]);
          final bgColor = bgColorValue != null
              ? Color(bgColorValue)
              : AppColors.primaryColor;

          return Container(
            color: bgColor,
            child: Image.asset(
              avatarPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildDefaultAvatar(currentUser),
            ),
          );
        }
      } else if (profilePic.startsWith('http')) {
        return Image.network(
          profilePic,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(currentUser),
        );
      } else if (profilePic.startsWith('assets/')) {
        return Image.asset(
          profilePic,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(currentUser),
        );
      } else {
        return Image.network(
          "${ApiConfig.baseImageUrl}/$profilePic",
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(currentUser),
        );
      }
    }

    return _buildDefaultAvatar(currentUser);
  }

  Widget _buildDefaultAvatar(User currentUser) {
    final initialsSize = _getResponsiveValue(
      context,
      mobile: 32.0,
      tablet: 38.0,
      desktop: 44.0,
    );

    return Image.asset(
      'assets/images/avatar_placeholder.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.primaryColor,
        child: Center(
          child: Text(
            _getInitials(currentUser.fullName),
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: initialsSize,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfilePictureOptions(BuildContext context, User currentUser) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => ProfilePictureOptionsSheet(
        user: currentUser,
        onDismiss: () => Navigator.pop(sheetContext),
      ),
    );
  }

  Widget _buildInfoSection({
    required String label,
    required String value,
    required BuildContext context,
    required String userId,
  }) {
    final labelSize = _getResponsiveValue(
      context,
      mobile: 10.5,
      tablet: 11.5,
      desktop: 12.5,
    );
    final valueSize = _getResponsiveValue(
      context,
      mobile: 12.5,
      tablet: 13.5,
      desktop: 14.5,
    );
    final actionSize = _getResponsiveValue(
      context,
      mobile: 10.5,
      tablet: 11.5,
      desktop: 12.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: labelSize,
            color: AppColors.grayColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: valueSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (label == 'Nama Lengkap') {
                  context.pushNamed(
                    'edit-name',
                    extra: {'userId': userId, 'currentName': value},
                  );
                } else if (label == 'Nomor Handphone') {
                  context.pushNamed(
                    'verify-password',
                    extra: {
                      'userId': userId,
                      'title': 'Ubah Nomor Handphone',
                      'subtitle': 'Masukkan password untuk verifikasi',
                      'nextRoute': 'edit-contact',
                      'nextRouteExtra': {
                        'currentPhone': value,
                        'type': 'phone',
                      },
                    },
                  );
                } else if (label == 'Email') {
                  context.pushNamed(
                    'verify-password',
                    extra: {
                      'userId': userId,
                      'title': 'Ubah Email',
                      'subtitle': 'Masukkan password untuk verifikasi',
                      'nextRoute': 'edit-contact',
                      'nextRouteExtra': {
                        'currentEmail': value,
                        'type': 'email',
                      },
                    },
                  );
                }
              },
              child: Text(
                'Ubah',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: actionSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
      ],
    );
  }

  Widget _buildCompanyCard(BuildContext context) {
    final imageSize = _getResponsiveValue(
      context,
      mobile: 85.0,
      tablet: 120.0,
      desktop: 140.0,
    );

    final textSize = _getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 13.0,
      desktop: 14.0,
    );

    final iconSize = _getResponsiveValue(
      context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    final cardPadding = _getResponsiveValue(
      context,
      mobile: 11.0,
      tablet: 15.0,
      desktop: 18.0,
    );

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[50] ?? const Color(0xFFE3F2FD),
            Colors.blue[25] ?? const Color(0xFFF5F9FD),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue[100] ?? const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/account/linkCompany.png',
              width: imageSize,
              height: imageSize * 0.85,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: imageSize,
                height: imageSize * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business_rounded,
                  size: imageSize * 0.4,
                  color: Colors.blue[200] ?? const Color(0xFF90CAF9),
                ),
              ),
            ),
          ),
          SizedBox(
            width: _getResponsiveValue(
              context,
              mobile: 11,
              tablet: 13,
              desktop: 15,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700] ?? const Color(0xFF1976D2),
                  size: iconSize,
                ),
                const SizedBox(height: 7),
                Text(
                  'Akses data transaksi dan fitur menarik lainnya',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: textSize,
                    color: Colors.grey[800] ?? const Color(0xFF424242),
                    height: 1.35,
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

  Widget _buildDynamicCompanyButton(BuildContext context, User currentUser) {
    final buttonHeight = _getResponsiveValue(
      context,
      mobile: 42,
      tablet: 46,
      desktop: 50,
    );
    final buttonTextSize = _getResponsiveValue(
      context,
      mobile: 12.5,
      tablet: 13.5,
      desktop: 14.5,
    );

    if (_isLoadingRegistration) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
            ),
          ),
        ),
      );
    }

    String buttonText;
    VoidCallback onPressed;
    final hasActiveCompany = (_activeBcName?.trim().isNotEmpty ?? false);

    if (hasActiveCompany) {
      buttonText = 'Tambah Perusahaan / Cabang';
      onPressed = () {
        context.pushNamed('companySelection');
      };
    } else if (_latestRegistration == null) {
      buttonText = 'Daftar Member';
      onPressed = () {
        context.pushNamed('memberRegistration');
      };
    } else {
      final status = _latestRegistration!.status;

      if (status == 'approved') {
        buttonText = 'Hubungkan Perusahaan';
        onPressed = () {
          context.pushNamed('companySelection');
        };
      } else {
        buttonText = 'Lihat Pengajuan Member';
        onPressed = () {
          context.pushNamed('memberList', extra: {'initialTabIndex': 0});
        };
      }
    }

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: buttonTextSize,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, User currentUser) {
    final horizontalPadding = _getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    final titleSize = _getResponsiveValue(
      context,
      mobile: 12.5,
      tablet: 13.5,
      desktop: 14.5,
    );
    final itemTextSize = _getResponsiveValue(
      context,
      mobile: 11.5,
      tablet: 12.5,
      desktop: 13.5,
    );
    final iconSize = _getResponsiveValue(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 14,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pengaturan dan Keamanan',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 10),

          _buildSettingItem(
            icon: Icons.business_center_outlined,
            iconSize: iconSize,
            textSize: itemTextSize,
            title: 'Lihat Perusahaan',
            onTap: () {
              context.pushNamed('memberList');
            },
          ),
          const Divider(height: 1),

          _buildSettingItem(
            icon: Icons.lock_outline,
            iconSize: iconSize,
            textSize: itemTextSize,
            title: 'Ganti Password',
            onTap: () {
              if (currentUser.password != "") {
                context.pushNamed(
                  'verify-password',
                  extra: {
                    'userId': currentUser.phone,
                    'title': 'Ganti Password',
                    'subtitle': 'Masukkan password untuk verifikasi',
                    'nextRoute': 'change-password',
                  },
                );
              } else {
                context.pushNamed(
                  'change-password',
                  extra: {'verifyOldPassword': "old"},
                );
              }
            },
          ),

          const Divider(height: 1),

          _buildSettingItem(
            icon: Icons.logout,
            iconSize: iconSize,
            textSize: itemTextSize,
            title: 'Log Out',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required double iconSize,
    required double textSize,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: iconSize, color: Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: textSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final titleSize = _getResponsiveValue(
      context,
      mobile: 15,
      tablet: 16,
      desktop: 17,
    );
    final contentSize = _getResponsiveValue(
      context,
      mobile: 12.5,
      tablet: 13.5,
      desktop: 14.5,
    );
    final buttonSize = _getResponsiveValue(
      context,
      mobile: 12.5,
      tablet: 13.5,
      desktop: 14.5,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Konfirmasi Logout',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: contentSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: buttonSize,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthSessionCubit>().logout();
              context.goNamed('home');
            },
            child: Text(
              'Logout',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: buttonSize,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
