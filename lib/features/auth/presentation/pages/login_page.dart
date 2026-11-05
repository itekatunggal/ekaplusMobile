// lib/features/auth/presentation/pages/login_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isNavigating = false;
  String? _identifierError;
  String? _passwordError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    if (_identifierError != null) return _identifierError;
    if (value == null || value.isEmpty) {
      return 'Nomor HP, email, atau username harus diisi';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (_passwordError != null) return _passwordError;
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    return null;
  }

  void _clearError(String field) {
    if (!mounted) return;
    setState(() {
      if (field == 'identifier') {
        _identifierError = null;
      } else if (field == 'password') {
        _passwordError = null;
      }
    });
  }

  void _onLoginPressed() {
    if (!mounted ||
        _isNavigating ||
        context.read<AuthBloc>().state is AuthLoading) {
      return;
    }

    setState(() {
      _identifierError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;

      context.read<AuthBloc>().add(
        LoginUserEvent(identifier: identifier, password: password),
      );
    }
  }

  void _showSuccessSnackbar(String name) {
    if (!mounted) return;

    final bool isIOS = io.Platform.isIOS;

    AppSnackbar.showRaw(
      context,
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Selamat datang, $name!',
                style: TextStyle(
                  fontSize: isIOS ? 14 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    final bool isIOS = io.Platform.isIOS;

    AppSnackbar.showRaw(
      context,
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: isIOS ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
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
      backgroundColor: Colors.white,
      appBar: const CustomHeaderAppBar(title: 'Masuk'),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!mounted) return;

          if (state is LoginError) {
            _isNavigating = false;
            setState(() {
              if (state.message.contains('tidak ditemukan') ||
                  state.message.toLowerCase().contains('user')) {
                _identifierError = state.message;
                _passwordError = null;
              } else if (state.message.contains('salah') ||
                  state.message.toLowerCase().contains('password')) {
                _identifierError = null;
                _passwordError = state.message;
              } else {
                _identifierError = state.message;
                _passwordError = null;
              }
            });
            _formKey.currentState!.validate();
          } else if (state is LoginSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            TextInput.finishAutofillContext(shouldSave: true);
            context.read<AuthSessionCubit>().login(state.user);
            _showSuccessSnackbar(state.user.fullName);

            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) context.go('/');
            });
          } else if (state is LoginWithGoogleSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            context.read<AuthSessionCubit>().login(state.user);
            _showSuccessSnackbar(state.user.fullName);

            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) context.go('/');
            });
          } else if (state is LoginWithGoogleError) {
            _isNavigating = false;
            _showErrorSnackbar(state.message);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: isSmallScreen ? 20 : 24,
                  ),
                  child: AutofillGroup(
                    onDisposeAction: AutofillContextAction.cancel,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Text
                          Text(
                            'Selamat datang kembali',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: isSmallScreen
                                  ? (isIOS ? 20 : 18)
                                  : (isIOS ? 24 : 22),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Masuk untuk melanjutkan belanja Anda',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: isIOS ? 14 : 12,
                              color: const Color(0xFF6B6B6B),
                              height: 1.4,
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 28 : 32),

                          // Identifier Input
                          _buildInputField(
                            controller: _identifierController,
                            label: 'Nomor HP / Email / Username',
                            hint: 'Masukkan nomor HP, email, atau username',
                            icon: Icons.person_outline_rounded,
                            error: _identifierError,
                            validator: _validateIdentifier,
                            keyboardType: TextInputType.text,
                            onChanged: (_) => _clearError('identifier'),
                            isIOS: isIOS,
                          ),

                          const SizedBox(height: 20),

                          // Password Input
                          _buildPasswordField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Masukkan password',
                            error: _passwordError,
                            validator: _validatePassword,
                            isPasswordVisible: _isPasswordVisible,
                            onToggleVisibility: () {
                              if (mounted) {
                                setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                );
                              }
                            },
                            onChanged: (_) => _clearError('password'),
                            isIOS: isIOS,
                          ),

                          const SizedBox(height: 12),

                          // // Forgot Password
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: () =>
                          //         context.pushNamed('forgot-password-phone'),
                          //     style: TextButton.styleFrom(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 8,
                          //         vertical: 4,
                          //       ),
                          //       minimumSize: Size.zero,
                          //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          //     ),
                          //     child: Text(
                          //       'Lupa Password?',
                          //       style: TextStyle(
                          //         fontFamily: AppFonts.primaryFont,
                          //         fontSize: isIOS ? 14 : 12,
                          //         fontWeight: FontWeight.w600,
                          //         color: AppColors.primaryColor,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Login Button
                          _buildLoginButton(isSmallScreen, isIOS),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Color(0xFFE5E7EB)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'atau masuk dengan',
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: isIOS ? 13 : 12,
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Color(0xFFE5E7EB)),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Google Sign In Button
                          _buildGoogleButton(isIOS),

                          SizedBox(height: isSmallScreen ? 24 : 32),

                          // Register Link
                          _buildRegisterLink(isIOS),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? error,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    required Function(String) onChanged,
    required bool isIOS,
  }) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: isIOS ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          autofillHints: const [AutofillHints.username],
          textInputAction: TextInputAction.next,
          style: TextStyle(
            fontSize: isIOS ? 15 : 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
              fontSize: isIOS ? 15 : 13,
            ),
            prefixIcon: Icon(
              icon,
              color: hasError
                  ? AppColors.primaryColor
                  : const Color(0xFF9CA3AF),
              size: 22,
            ),
            filled: true,
            fillColor: hasError
                ? AppColors.primaryColor.withOpacity(0.04)
                : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.primaryColor
                    : AppColors.secondaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorStyle: TextStyle(
              color: AppColors.primaryColor,
              fontSize: isIOS ? 12 : 10,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? error,
    required String? Function(String?) validator,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    required Function(String) onChanged,
    required bool isIOS,
  }) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: isIOS ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onLoginPressed(),
          style: TextStyle(
            fontSize: isIOS ? 15 : 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
              fontSize: isIOS ? 15 : 13,
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: hasError
                  ? AppColors.primaryColor
                  : const Color(0xFF9CA3AF),
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF9CA3AF),
                size: 22,
              ),
              onPressed: onToggleVisibility,
              splashRadius: 20,
            ),
            filled: true,
            fillColor: hasError
                ? AppColors.primaryColor.withOpacity(0.04)
                : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.primaryColor
                    : AppColors.secondaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorStyle: TextStyle(
              color: AppColors.primaryColor,
              fontSize: isIOS ? 12 : 10,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isSmallScreen, bool isIOS) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (isLoading || _isNavigating) ? null : _onLoginPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.secondaryColor.withOpacity(
                0.5,
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Masuk',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: isIOS ? 15 : 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton(bool isIOS) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () => context.read<AuthBloc>().add(LoginWithGoogleEvent()),

            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1F2937),
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF9CA3AF),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        width: 22,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.g_mobiledata, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Google',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: isIOS ? 15 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterLink(bool isIOS) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Belum punya akun? ',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: isIOS ? 14 : 12,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          TextButton(
            onPressed: () {
              if (!_isNavigating) {
                context.push('/register');
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Daftar Sekarang',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: isIOS ? 14 : 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
