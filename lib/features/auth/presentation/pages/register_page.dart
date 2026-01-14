// lib/features/auth/presentation/pages/register_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin, RouteAware {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isNavigating = false;
  String? _phoneErrorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  void _safeShowSnackBar(SnackBar snackBar) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetNavigationState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _resetNavigationState() {
    if (mounted) {
      setState(() {
        _isNavigating = false;
      });
    }
  }

  void _triggerShake() {
    _shakeController.forward(from: 0).then((_) {
      _shakeController.reverse();
    });
  }

  String? _validatePhone(String? value) {
    if (_phoneErrorMessage != null) {
      return _phoneErrorMessage;
    }

    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }

    if (cleanPhone.length > 13) {
      return 'Nomor telepon maksimal 13 digit';
    }

    if (!cleanPhone.startsWith('0') && !cleanPhone.startsWith('62')) {
      return 'Nomor harus diawali 0 atau 62';
    }

    return null;
  }

  String _normalizePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    }

    return cleaned;
  }

  void _onNextPressed() {
    setState(() {
      _phoneErrorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final normalizedPhone = _normalizePhone(_phoneController.text);
      context.read<AuthBloc>().add(CheckPhoneEvent(normalizedPhone));
    }
  }

  void _showSuccessSnackBar(String message) {
    final bool isIOS = io.Platform.isIOS;

    _safeShowSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondaryColor,
                AppColors.secondaryColor.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isIOS ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final bool isIOS = io.Platform.isIOS;

    _safeShowSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: isIOS ? 14 : 12)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.whiteColor,
      appBar: const CustomHeaderAppBar(title: 'Daftar'),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            _resetNavigationState();
          }

          if (state is PhoneCheckSuccess) {
            if (state.exists) {
              setState(() {
                _phoneErrorMessage =
                    'Nomor ini sudah terdaftar. Silakan login atau gunakan nomor lain.';
                _isNavigating = false;
              });
              _formKey.currentState!.validate();
              _triggerShake();
            } else {
              final normalizedPhone = _normalizePhone(_phoneController.text);
              context.read<AuthBloc>().add(RegisterOtpEvent(normalizedPhone));
            }
          } else if (state is PhoneCheckError) {
            setState(() {
              _phoneErrorMessage = state.message;
              _isNavigating = false;
            });
            _formKey.currentState!.validate();
            _triggerShake();
          } else if (state is OtpRequestSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            _showSuccessSnackBar(
              '📱 Kode verifikasi 6 digit telah dikirim ke WhatsApp Anda',
            );

            Future.microtask(() {
              if (!mounted) return;
              context.push('/otp', extra: state.phone).then((_) {
                if (!mounted) return;
                setState(() {
                  _isNavigating = false;
                });
              });
            });
          } else if (state is OtpRequestError) {
            setState(() {
              _phoneErrorMessage = state.message;
              _isNavigating = false;
            });
            _formKey.currentState!.validate();
            _triggerShake();
          } else if (state is LoginWithGoogleSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            FocusScope.of(context).unfocus();
            context.read<AuthSessionCubit>().login(state.user);

            _showSuccessSnackBar('Selamat datang, ${state.user.fullName}! 👋');

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.go('/');
            });
          } else if (state is LoginWithGoogleError) {
            setState(() {
              _isNavigating = false;
            });
            _showErrorSnackBar(state.message);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  isSmallScreen ? 16 : 24,
                  20,
                  20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      _buildInfoCard(isSmallScreen, isIOS),

                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Phone Input
                      _buildPhoneInput(isSmallScreen, isIOS),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Helper Text
                      _buildHelperText(isSmallScreen, isIOS),

                      SizedBox(height: isSmallScreen ? 32 : 40),

                      // Divider
                      _buildDivider(isSmallScreen, isIOS),

                      SizedBox(height: isSmallScreen ? 32 : 40),

                      // Google Sign In Button
                      _buildGoogleButton(isSmallScreen, isIOS),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Section
            _buildBottomSection(isSmallScreen, isIOS),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isSmallScreen, bool isIOS) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryColor.withOpacity(0.1),
            AppColors.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.secondaryColor,
              size: isSmallScreen ? 22 : 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi WhatsApp',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isSmallScreen
                        ? (isIOS ? 13 : 12)
                        : (isIOS ? 14 : 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode OTP akan dikirim via WhatsApp',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? (isIOS ? 11 : 10)
                        : (isIOS ? 12 : 11),
                    color: AppColors.grayColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(bool isSmallScreen, bool isIOS) {
    final hasError = _phoneErrorMessage != null;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nomor Handphone',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: isSmallScreen ? (isIOS ? 13 : 12) : (isIOS ? 14 : 12),
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: isSmallScreen ? (isIOS ? 14 : 12) : (isIOS ? 15 : 13),
              fontWeight: FontWeight.w500,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
            decoration: InputDecoration(
              hintText: 'Contoh: 0812xxx atau 62812xxxx',
              hintStyle: TextStyle(
                color: AppColors.grayColor.withOpacity(0.6),
                fontWeight: FontWeight.w400,
                fontSize: isSmallScreen ? (isIOS ? 14 : 12) : (isIOS ? 15 : 13),
              ),
              prefixIcon: Icon(
                Icons.phone_android_rounded,
                color: hasError ? AppColors.primaryColor : AppColors.grayColor,
                size: isSmallScreen ? 20 : 22,
              ),
              filled: true,
              fillColor: hasError
                  ? AppColors.primaryColor.withOpacity(0.03)
                  : Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.primaryColor.withOpacity(0.3)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.primaryColor
                      : AppColors.secondaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              errorStyle: TextStyle(
                color: AppColors.primaryColor,
                fontSize: isSmallScreen ? (isIOS ? 11 : 9) : (isIOS ? 12 : 10),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            validator: _validatePhone,
            onChanged: (value) {
              if (_phoneErrorMessage != null) {
                setState(() {
                  _phoneErrorMessage = null;
                });
                _formKey.currentState?.validate();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelperText(bool isSmallScreen, bool isIOS) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: isSmallScreen ? 14 : 16,
          color: Colors.green.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Nomor Anda akan digunakan untuk login dan verifikasi',
            style: TextStyle(
              fontSize: isSmallScreen ? (isIOS ? 11 : 10) : (isIOS ? 12 : 11),
              color: AppColors.grayColor,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isSmallScreen, bool isIOS) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, color: Color(0xFFE0E0E0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'atau',
            style: TextStyle(
              fontSize: isSmallScreen ? (isIOS ? 12 : 11) : (isIOS ? 13 : 12),
              color: AppColors.grayColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1, color: Color(0xFFE0E0E0))),
      ],
    );
  }

  Widget _buildGoogleButton(bool isSmallScreen, bool isIOS) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return OutlinedButton(
          onPressed: (isLoading || _isNavigating)
              ? null
              : () {
                  context.read<AuthBloc>().add(LoginWithGoogleEvent());
                },
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, isSmallScreen ? 50 : 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
            backgroundColor: AppColors.whiteColor,
            foregroundColor: AppColors.blackColor,
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.grayColor,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/google.png',
                      width: isSmallScreen ? 20 : 24,
                      height: isSmallScreen ? 20 : 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.g_mobiledata,
                          size: isSmallScreen ? 20 : 24,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Daftar dengan Google',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: isSmallScreen
                            ? (isIOS ? 14 : 12)
                            : (isIOS ? 15 : 13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildBottomSection(bool isSmallScreen, bool isIOS) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            isSmallScreen ? 16 : 20,
            20,
            isSmallScreen ? 16 : 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Next Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return ElevatedButton(
                    onPressed: (isLoading || _isNavigating)
                        ? null
                        : _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: AppColors.blackColor,
                      disabledBackgroundColor: AppColors.secondaryColor
                          .withOpacity(0.5),
                      minimumSize: Size(
                        double.infinity,
                        isSmallScreen ? 50 : 56,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.blackColor,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Selanjutnya',
                                style: TextStyle(
                                  fontFamily: AppFonts.primaryFont,
                                  fontWeight: FontWeight.w700,
                                  fontSize: isSmallScreen
                                      ? (isIOS ? 15 : 13)
                                      : (isIOS ? 16 : 14),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  );
                },
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun?  ',
                    style: TextStyle(
                      fontSize: isSmallScreen
                          ? (isIOS ? 13 : 11)
                          : (isIOS ? 14 : 12),
                      color: AppColors.grayColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!_isNavigating) {
                        context.push('/login');
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: isSmallScreen
                            ? (isIOS ? 13 : 11)
                            : (isIOS ? 14 : 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
