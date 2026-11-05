// lib/features/auth/presentation/pages/otp_verification_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_contact_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String? title;
  final String? subtitle;
  final String? nextRoute;
  final bool isPasswordReset;
  final ProfileUpdateCubit? cubit;
  final String? userId;
  final ContactType? contactType;
  final String? password;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    this.title,
    this.subtitle,
    this.nextRoute,
    this.isPasswordReset = false,
    this.cubit,
    this.userId,
    this.contactType,
    this.password,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  TextEditingController? _otpController;
  FocusNode? _pinFocusNode;
  StreamController<ErrorAnimationType>? _errorController;

  void _safeShowSnackBar(SnackBar snackBar) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    AppSnackbar.showRaw(context, snackBar);
  }

  bool _hasError = false;
  String _currentOtp = '';
  bool _isNavigating = false;
  bool _isDisposed = false;

  bool get isProfileUpdate => widget.cubit != null;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _pinFocusNode = FocusNode();
    _errorController = StreamController<ErrorAnimationType>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _pinFocusNode?.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _errorController?.close();
    _pinFocusNode?.dispose();
    _otpController?.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_isDisposed || _isNavigating) return;
    if (_currentOtp.length != 6) return;

    if (isProfileUpdate) {
      context.pushNamed(
        widget.nextRoute!,
        extra: {
          'userId': widget.userId,
          'newValue': widget.phoneNumber,
          'verificationCode': _currentOtp,
          'type': widget.contactType,
          'cubit': widget.cubit,
        },
      );
    } else {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(widget.phoneNumber, _currentOtp, "wa"),
      );
    }
  }

  void _resendOtp() {
    if (_isDisposed) return;

    setState(() {
      _hasError = false;
      _currentOtp = '';
    });

    _otpController?.clear();

    if (isProfileUpdate) {
      if (widget.contactType == ContactType.phone) {
        widget.cubit?.requestPhoneUpdate(
          userId: widget.userId!,
          newPhone: widget.phoneNumber,
          password: widget.password ?? '',
        );
      } else {
        widget.cubit?.requestEmailUpdate(
          userId: widget.userId!,
          newEmail: widget.phoneNumber,
          password: widget.password ?? '',
        );
      }
    } else {
      context.read<AuthBloc>().add(RequestOtpEvent(widget.phoneNumber));
    }

    context.read<OtpTimerBloc>().add(const StartOtpTimer(duration: 60));
  }

  void _showOtpError() {
    if (_isDisposed) return;

    setState(() {
      _hasError = true;
    });

    _errorController?.add(ErrorAnimationType.shake);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _isDisposed) return;
      _otpController?.clear();
      setState(() {
        _currentOtp = '';
      });
    });
  }

  void _handleBack() {
    if (_isDisposed || _isNavigating) return;
    context.read<OtpTimerBloc>().add(ResetOtpTimer());
    if (!isProfileUpdate) {
      context.read<AuthBloc>().add(ResetAuthEvent());
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomHeaderAppBar(
          title: widget.title ?? 'Verifikasi OTP',
          subtitle: 'Masukkan kode OTP yang telah dikirim',
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpVerificationSuccess) {
              if (_isNavigating) return;
              _isNavigating = true;

              _safeShowSnackBar(
                const SnackBar(
                  content: Text('✅ OTP berhasil diverifikasi!'),
                  backgroundColor: Colors.green,
                ),
              );

              context.read<OtpTimerBloc>().add(ResetOtpTimer());

              Future.delayed(const Duration(milliseconds: 400), () {
                if (!mounted) return;
                _isNavigating = false;

                if (widget.nextRoute != null) {
                  context.pushNamed(
                    widget.nextRoute!,
                    extra: widget.phoneNumber,
                  );
                } else {
                  context.pushNamed('registerForm', extra: widget.phoneNumber);
                }
              });
            } else if (state is OtpVerificationError) {
              _showOtpError();
            }
          },
          child: _buildOtpBody(),
        ),
      ),
    );
  }

  Widget _buildOtpBody() {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (10 * 2) - (4 * 2 * 6);
    final fieldSize = (availableWidth / 6).clamp(44.0, 64.0);
    final fontSize = (fieldSize * 0.4).clamp(20.0, 28.0);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController!,
                    focusNode: _pinFocusNode!,
                    keyboardType: TextInputType.number,
                    enableActiveFill: true,
                    errorAnimationController: _errorController!,
                    textStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primaryFont,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: fieldSize,
                      fieldWidth: fieldSize,
                      fieldOuterPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.grey[100],
                      activeColor: const Color(0xFF2196F3),
                      selectedColor: const Color(0xFF2196F3),
                      inactiveColor: AppColors.grayColor.withOpacity(0.3),
                      errorBorderColor: AppColors.primaryColor,
                    ),
                    onChanged: (value) {
                      if (_hasError && value.isNotEmpty) {
                        setState(() => _hasError = false);
                      }
                      _currentOtp = value;
                    },

                    onCompleted: (value) {
                      if (_isDisposed || _isNavigating) return;

                      _currentOtp = value;

                      Future.microtask(() {
                        if (mounted && !_isDisposed) {
                          _verifyOtp();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  opacity: _hasError ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text(
                    'OTP tidak valid',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildResendSection(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: (_isNavigating || _isDisposed) ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: AppColors.secondaryColor,
            ),
            child: const Text('Selanjutnya'),
          ),
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return BlocBuilder<OtpTimerBloc, OtpTimerState>(
      builder: (context, state) {
        if (state is OtpTimerRunning) {
          return Text('Kirim ulang dalam ${state.formattedTime}');
        }
        return GestureDetector(
          onTap: _resendOtp,
          child: const Text(
            'Kirim Ulang Kode',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
