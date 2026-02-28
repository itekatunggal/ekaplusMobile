// lib/core/shared_widgets/profile_header.dart
import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/widgets/company_picker_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileHeader extends StatefulWidget {
  final VoidCallback? onCompanyTap;

  const ProfileHeader({super.key, this.onCompanyTap});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  int? _lastLoadedUserId;

  void _showActiveCompanyToast(String message) {
    AppSnackbar.show(
      context,
      message: message,
      type: AppSnackbarType.success,
    );
  }

  Future<void> _showCompanyPicker() async {
    final activeCubit = context.read<ActiveCompanyCubit>();
    final state = activeCubit.state;
    final companies = state is ActiveCompanyReady
        ? state.companies
        : const <ActiveMemberCompany>[];
    final activeBcid = state is ActiveCompanyReady ? state.activeBcid : null;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CompanyPickerSheet(
        companies: companies,
        activeBcid: activeBcid,
        onSelectCompany: (selected) async {
          try {
            final changed = await activeCubit.setActiveCompany(selected);
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            if (!mounted) return;
            if (changed) {
              _showActiveCompanyToast(
                '${selected.displayName} menjadi perusahaan aktif',
              );
            } else {
              AppSnackbar.show(
                context,
                message: 'Perusahaan belum memiliki BCID valid',
                type: AppSnackbarType.error,
              );
            }
          } catch (e) {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            if (!mounted) return;
            AppSnackbar.show(
              context,
              message: 'Gagal memilih perusahaan aktif: $e',
              type: AppSnackbarType.error,
            );
          }
        },
        onAddCompany: () {
          Navigator.of(dialogContext).pop();
          context.pushNamed('companySelection');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final media = MediaQuery.of(context);

    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(media.textScaleFactor.clamp(0.8, 1.0)),
      ),
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, authState) {
          if (authState is AuthSessionAuthenticated) {
            final userId = authState.user.id;
            final shouldForceReload = _lastLoadedUserId != userId;
            _lastLoadedUserId = userId;

            final activeState = context.read<ActiveCompanyCubit>().state;
            if (shouldForceReload ||
                (activeState is! ActiveCompanyReady &&
                    activeState is! ActiveCompanyLoading)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.read<ActiveCompanyCubit>().loadCompaniesAndResolveActive(
                  force: shouldForceReload,
                );
              });
            }
          }
          Widget buildAvatar() {
            if (authState is AuthSessionAuthenticated) {
              final user = authState.user;

              final String profilePic = (user.profilePic.isNotEmpty)
                  ? user.profilePic
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
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultAvatar(user.fullName),
                      ),
                    );
                  }
                } else if (profilePic.startsWith('http')) {
                  return Image.network(
                    profilePic,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultAvatar(user.fullName),
                  );
                } else if (profilePic.startsWith('assets/')) {
                  return Image.asset(
                    profilePic,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultAvatar(user.fullName),
                  );
                } else {
                  return Image.network(
                    "${ApiConfig.baseImageUrl}/$profilePic",
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultAvatar(user.fullName),
                  );
                }
              }

              return _buildDefaultAvatar(user.fullName);
            }

            return Image.asset(
              'assets/images/avatar_placeholder.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryColor,
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
            );
          }

          Widget buildTextArea() {
            if (authState is AuthSessionGuest) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, Selamat Datang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primaryFont,
                      color: AppColors.blackColor,
                      fontSize: isIOS ? 15 : 13,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Masuk atau Daftar Sekarang',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: isIOS ? 11.5 : 10,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: isIOS ? 18 : 16,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ],
              );
            }

            if (authState is AuthSessionAuthenticated) {
              final user = authState.user;
              final canPickCompany = authState.isMember;

              if (!canPickCompany) {
                return Text(
                  'Halo, ${user.firstName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.primaryFont,
                    color: AppColors.blackColor,
                    fontSize: isIOS ? 16 : 14,
                    letterSpacing: -0.3,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user.firstName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primaryFont,
                      color: AppColors.blackColor,
                      fontSize: isIOS ? 16 : 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  BlocBuilder<ActiveCompanyCubit, ActiveCompanyState>(
                    builder: (context, state) {
                      final companyLabel = state is ActiveCompanyLoading
                          ? 'Memuat perusahaan...'
                          : state is ActiveCompanyReady
                          ? (state.activeCompany?.displayName ??
                                'Belum terhubung dengan perusahaan')
                          : 'Belum terhubung dengan perusahaan';
                      return GestureDetector(
                        onTap: canPickCompany
                            ? (widget.onCompanyTap ?? _showCompanyPicker)
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: Text(
                                companyLabel,
                                key: ValueKey(companyLabel),
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: isIOS ? 12 : 10,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFonts.primaryFont,
                                ),
                              ),
                            ),
                            if (canPickCompany) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.expand_more, size: isIOS ? 18 : 16),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }

            return Text(
              'Memuat...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.primaryFont,
                color: AppColors.blackColor,
                fontSize: isIOS ? 15 : 13,
              ),
            );
          }

          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed('account');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(child: buildAvatar()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: buildTextArea()),
                    ],
                  ),
                ),
              ),
              // IconButton(
              //   onPressed: () {
              //     AppSnackbar.showRaw(context, 
              //       const SnackBar(content: Text('Notifikasi (segera hadir)')),
              //     );
              //   },
              //   icon: const Icon(
              //     CupertinoIcons.bell_solid,
              //     color: AppColors.grayColor,
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(String fullName) {
    return Container(
      color: AppColors.primaryColor,
      child: Center(
        child: Text(
          _getInitials(fullName),
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
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
