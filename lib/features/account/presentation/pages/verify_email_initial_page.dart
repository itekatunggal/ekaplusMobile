// lib/features/account/presentation/pages/verify_email_initial_page.dart
import 'dart:async';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyEmailInitialPage extends StatefulWidget {
  final String userId;
  final String email;

  const VerifyEmailInitialPage({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<VerifyEmailInitialPage> createState() => _VerifyEmailInitialPageState();
}

class _VerifyEmailInitialPageState extends State<VerifyEmailInitialPage> {
  TextEditingController? _otpController;
  FocusNode? _pinFocusNode;
  StreamController<ErrorAnimationType>? _errorController;
  bool _hasError = false;
  String _currentOtp = '';
  bool _isNavigating = false;
  bool _isDisposed = false;
  bool _isInitialRequestSent = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Send initial verification request
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed && !_isInitialRequestSent) {
        _isInitialRequestSent = true;
        _requestInitialEmailVerification();
      }
    });
  }

  void _initializeControllers() {
    _otpController = TextEditingController();
    _pinFocusNode = FocusNode();
    _errorController = StreamController<ErrorAnimationType>();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _errorController?.close();
    try {
      _pinFocusNode?.dispose();
    } catch (e) {
      debugPrint('⚠️ FocusNode error on dispose: $e');
    }
    try {
      _otpController?.dispose();
    } catch (e) {
      debugPrint('⚠️ OTP Controller error on dispose: $e');
    }
    _pinFocusNode = null;
    _otpController = null;
    _errorController = null;
    super.dispose();
  }

  void _requestInitialEmailVerification() {
    if (_isDisposed || !mounted) return;

    context.read<ProfileUpdateCubit>().requestInitialEmailVerification(
      userId: widget.userId,
      email: widget.email,
    );

    // Start timer
    context.read<OtpTimerBloc>().add(const StartOtpTimer(duration: 60));
  }

  void _verifyOtp() {
    if (_isDisposed || _isNavigating) return;
    if (_currentOtp.isEmpty || _currentOtp.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan masukkan kode verifikasi 6 digit'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
      return;
    }

    context.read<ProfileUpdateCubit>().verifyInitialEmail(
      userId: widget.userId,
      email: widget.email,
      verificationCode: _currentOtp,
    );
  }

  void _resendOtp() {
    if (_isDisposed) return;
    if (mounted) {
      setState(() {
        _hasError = false;
        _currentOtp = '';
      });
      _otpController?.clear();

      context.read<ProfileUpdateCubit>().requestInitialEmailVerification(
        userId: widget.userId,
        email: widget.email,
      );

      context.read<OtpTimerBloc>().add(const StartOtpTimer(duration: 60));
    }
  }

  void _showOtpError(String message) {
    if (_isDisposed || !mounted) return;
    setState(() {
      _hasError = true;
    });
    _errorController?.add(ErrorAnimationType.shake);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primaryColor),
    );

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
    if (mounted) {
      context.read<OtpTimerBloc>().add(ResetOtpTimer());
      context.goNamed('account');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed ||
        _otpController == null ||
        _pinFocusNode == null ||
        _errorController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        resizeToAvoidBottomInset: false,
        appBar: CustomHeaderAppBar(
          title: 'Verifikasi Email',
          subtitle: 'Kode verifikasi telah dikirim ke email Anda',
          onBackPressed: _handleBack,
        ),
        body: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
          listener: (context, state) {
            if (state is ProfileUpdateAwaitingVerification) {
              // Show OTP code in snackbar for testing
              if (mounted && !_isDisposed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            } else if (state is ProfileUpdateSuccess) {
              // Email verified successfully
              if (_isNavigating || _isDisposed) return;
              _isNavigating = true;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Email berhasil diverifikasi!'),
                  backgroundColor: Colors.green,
                ),
              );

              context.read<OtpTimerBloc>().add(ResetOtpTimer());

              // Update session with new user data
              context.read<AuthSessionCubit>().updateUser(state.user);

              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted || _isDisposed) return;
                _isNavigating = false;

                // Go back to account page
                // ignore: use_build_context_synchronously
                context.goNamed('account');
              });
            } else if (state is ProfileUpdateError) {
              _showOtpError(state.message);
            }
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // 🔥 Responsive calculation (sama seperti otp_verification_page)
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth =
        screenWidth - (20 * 2) - (4 * 2 * 6); // padding + gaps
    final fieldSize = (availableWidth / 6).clamp(45.0, 60.0);
    final fontSize = (fieldSize * 0.42).clamp(20.0, 26.0);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Info text with icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 64,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verifikasi Email Anda',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan kode verifikasi 6 digit yang telah kami kirimkan ke email:',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 13,
                          color: AppColors.grayColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 🔥 Responsive OTP Input (sama seperti otp_verification_page)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PinCodeTextField(
                    enabled: !_isNavigating && !_isDisposed,
                    appContext: context,
                    length: 6,
                    controller: _otpController!,
                    focusNode: _pinFocusNode!,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    autoFocus: true,
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
                      activeFillColor: AppColors.whiteColor,
                      activeColor: const Color(0xFF2196F3),
                      activeBorderWidth: 2,
                      selectedFillColor: AppColors.whiteColor,
                      selectedColor: const Color(0xFF2196F3),
                      selectedBorderWidth: 2,
                      inactiveFillColor: Colors.grey[100],
                      inactiveColor: AppColors.grayColor.withOpacity(0.3),
                      inactiveBorderWidth: 1.5,
                      errorBorderColor: AppColors.primaryColor,
                      errorBorderWidth: 2,
                    ),
                    onChanged: (value) {
                      if (_isDisposed) return;
                      if (_hasError && value.isNotEmpty && mounted) {
                        setState(() {
                          _hasError = false;
                        });
                      }
                      if (mounted) {
                        setState(() {
                          _currentOtp = value;
                        });
                      }
                    },
                    // 🔥 Auto-verify saat OTP selesai diinput
                    onCompleted: (value) {
                      if (_isDisposed || _isNavigating) return;

                      _currentOtp = value;

                      Future.microtask(() {
                        if (mounted && !_isDisposed) {
                          _verifyOtp();
                        }
                      });
                    },
                    beforeTextPaste: (text) {
                      return text?.contains(RegExp(r'^[0-9]+$')) ?? false;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Error message
                AnimatedOpacity(
                  opacity: _hasError ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Kode verifikasi salah!',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Resend section
                _buildResendSection(),
              ],
            ),
          ),
        ),

        // Verify button
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: (_isNavigating || _isDisposed) ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: AppColors.blackColor,
              disabledBackgroundColor: Colors.grey[300],
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Verifikasi Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    if (_isDisposed) return const SizedBox.shrink();
    return BlocBuilder<OtpTimerBloc, OtpTimerState>(
      builder: (context, timerState) {
        if (timerState is OtpTimerRunning) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak menerima kode?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim ulang dalam ${timerState.formattedTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (timerState is OtpTimerCompleted ||
            timerState is OtpTimerInitial) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak menerima kode?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _resendOtp,
                    child: const Text(
                      'Kirim Ulang Kode',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
