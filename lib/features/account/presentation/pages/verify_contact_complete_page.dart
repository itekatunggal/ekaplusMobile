// lib/features/account/presentation/pages/verify_contact_complete_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_contact_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerifyContactCompletePage extends StatefulWidget {
  final String userId;
  final String newValue;
  final String verificationCode;
  final ContactType type;
  final ProfileUpdateCubit cubit;

  const VerifyContactCompletePage({
    super.key,
    required this.userId,
    required this.newValue,
    required this.verificationCode,
    required this.type,
    required this.cubit,
  });

  @override
  State<VerifyContactCompletePage> createState() =>
      _VerifyContactCompletePageState();
}

class _VerifyContactCompletePageState extends State<VerifyContactCompletePage> {
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // Immediately trigger verification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isVerifying && mounted) {
        _verifyContact();
      }
    });
  }

  void _verifyContact() {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    if (widget.type == ContactType.phone) {
      widget.cubit.verifyPhoneUpdate(
        userId: widget.userId,
        newPhone: widget.newValue,
        verificationCode: widget.verificationCode,
      );
    } else {
      widget.cubit.verifyEmailUpdate(
        userId: widget.userId,
        newEmail: widget.newValue,
        verificationCode: widget.verificationCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileUpdateCubit>.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: BlocConsumer<ProfileUpdateCubit, ProfileUpdateState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              context.read<AuthSessionCubit>().updateUser(state.user);

              // Show success message
              AppSnackbar.showRaw(context, 
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Navigate back to account page after short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  // Pop all the way back to account page
                  context.go('/account');
                }
              });
            } else if (state is ProfileUpdateError) {
              setState(() {
                _isVerifying = false;
              });

              // Show error message
              AppSnackbar.showRaw(context, 
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );

              // Go back to OTP page after showing error
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  context.pop();
                }
              });
            }
          },
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Memverifikasi ${widget.type == ContactType.phone ? 'nomor handphone' : 'email'}...',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (state is ProfileUpdateError) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
