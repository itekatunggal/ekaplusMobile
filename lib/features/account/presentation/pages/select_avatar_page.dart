// lib/features/account/presentation/pages/select_avatar_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/services/avatar_local_storage.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectAvatarPage extends StatefulWidget {
  final User user;

  const SelectAvatarPage({super.key, required this.user});

  @override
  State<SelectAvatarPage> createState() => _SelectAvatarPageState();
}

class _SelectAvatarPageState extends State<SelectAvatarPage> {
  final List<String> avatars = [
    'assets/images/avatars/avatar_1.png',
    'assets/images/avatars/avatar_2.png',
    'assets/images/avatars/avatar_3.png',
    'assets/images/avatars/avatar_4.png',
    'assets/images/avatars/avatar_5.png',
    'assets/images/avatars/avatar_6.png',
    'assets/images/avatars/avatar_7.png',
    'assets/images/avatars/avatar_8.png',
    'assets/images/avatars/avatar_9.png',
    'assets/images/avatars/avatar_10.png',
    'assets/images/avatars/avatar_11.png',
    'assets/images/avatars/avatar_12.png',
    'assets/images/avatars/avatar_13.png',
    'assets/images/avatars/avatar_14.png',
    'assets/images/avatars/avatar_15.png',
    'assets/images/avatars/avatar_16.png',
    'assets/images/avatars/avatar_17.png',
    'assets/images/avatars/avatar_18.png',
    'assets/images/avatars/avatar_19.png',
    'assets/images/avatars/avatar_20.png',
    'assets/images/avatars/avatar_21.png',
    'assets/images/avatars/avatar_22.png',
    'assets/images/avatars/avatar_23.png',
    'assets/images/avatars/avatar_24.png',
  ];

  final List<Color> bgColors = [
    const Color(0xFFC61633),
    const Color(0xFFE43C4A),
    const Color(0xFFF08D8E),
    const Color(0xFFE5B729),
    const Color(0xFFFEDC63),
    const Color(0xFFFFF2B4),
    const Color(0xFF4F4F4F),
    const Color(0xFFBDBDBD),
    const Color(0xFF5366FC),
    const Color(0xFF56E0FF),
    const Color(0xFFB6FFA6),
  ];

  String? selectedAvatar;
  Color selectedBgColor = AppColors.primaryColor;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.profilePic.startsWith('assets/')) {
      selectedAvatar = widget.user.profilePic;
    } else {
      selectedAvatar = avatars[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: 'Pilih Avatar',
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Preview Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(0),
            color: selectedBgColor,
            child: Column(
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: selectedBgColor,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: selectedAvatar != null
                        ? Image.asset(
                            selectedAvatar!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Selection Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Pilih Avatar',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final spacing = 16.0;
                        // hitung itemSize agar 3 kolom rapi (perhatikan padding/spacing)
                        final itemSize =
                            (constraints.maxWidth - (spacing * 2)) / 3;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: avatars.map((avatar) {
                            final isSelected = selectedAvatar == avatar;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAvatar = avatar;
                                });
                              },
                              child: SizedBox(
                                width: itemSize,
                                height: itemSize,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Circle with border and avatar image (centered with padding)
                                    Center(
                                      child: Container(
                                        width: itemSize,
                                        height: itemSize,
                                        decoration: BoxDecoration(
                                          color: selectedBgColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : Colors.grey.shade300,
                                            width: isSelected ? 3 : 1,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            color: Colors.transparent,
                                            child: Image.asset(
                                              avatar,
                                              fit: BoxFit.contain,
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Check icon (posisi sedikit keluar dari lingkaran seperti mock)
                                    if (isSelected)
                                      Positioned(
                                        top: -6,
                                        right: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.15,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Atur Warna Background',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 70, // tinggi area selector warna
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: bgColors.map((color) {
                            final isSelected = selectedBgColor == color;

                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedBgColor = color;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade300,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 24,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

          // Save Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveAvatar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.secondaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black87,
                        ),
                      ),
                    )
                  : Text(
                      'Simpan',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAvatar() async {
    if (selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih avatar terlebih dahulu',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // Save context references before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authSessionCubit = context.read<AuthSessionCubit>();

    try {
      // Save original profile pic (jika ada dan bukan local avatar) sebagai backup
      final currentProfilePic = widget.user.profilePic;
      if (currentProfilePic.isNotEmpty && !currentProfilePic.startsWith('local:')) {
        await AvatarLocalStorage.saveOriginalProfilePic(currentProfilePic);
      }

      // Save avatar to local storage (tidak upload ke server)
      await AvatarLocalStorage.saveLocalAvatar(
        avatarPath: selectedAvatar!,
        bgColor: selectedBgColor.value.toString(),
      );

      // Update user profilePic dengan format khusus untuk local avatar
      // Format: "local:avatarPath|bgColor"
      final localAvatarData = 'local:${selectedAvatar!}|${selectedBgColor.value}';
      final updatedUser = widget.user.copyWith(profilePic: localAvatarData);

      // Update user state via AuthSessionCubit
      await authSessionCubit.updateUser(updatedUser);

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Avatar berhasil diubah',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Go back
      navigator.pop();
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan avatar: $e',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
