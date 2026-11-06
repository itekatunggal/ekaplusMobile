import 'dart:io';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _showApplePreviewOnAndroid = bool.fromEnvironment(
    'SHOW_APPLE_SIGN_IN_PREVIEW',
  );

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isNavigating = false;
  bool _isGoogleSubmitting = false;
  bool _isAppleSubmitting = false;
  String? _identifierError;
  String? _passwordError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================================
  // CLOSE / GUEST
  // ================================

  void _closeLogin() {
    if (_isNavigating) return;
    FocusScope.of(context).unfocus();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  // ================================
  // VALIDATION
  // ================================

  String? _validateIdentifier(String? value) {
    if (_identifierError != null) {
      return _identifierError;
    }
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP, email, atau username harus diisi';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (_passwordError != null) {
      return _passwordError;
    }
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    return null;
  }

  void _clearError({required bool identifier}) {
    final hasError = identifier
        ? _identifierError != null
        : _passwordError != null;
    if (!hasError) return;
    setState(() {
      if (identifier) {
        _identifierError = null;
      } else {
        _passwordError = null;
      }
    });
  }

  // ================================
  // LOGIN
  // ================================

  void _onLoginPressed() {
    if (_isNavigating || context.read<AuthBloc>().state is AuthLoading) {
      return;
    }
    setState(() {
      _identifierError = null;
      _passwordError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    _isGoogleSubmitting = false;
    _isAppleSubmitting = false;
    context.read<AuthBloc>().add(
      LoginUserEvent(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _handleLoginError(String message) {
    final normalized = message.toLowerCase();
    final looksLikeIdentifierError =
        normalized.contains('tidak ditemukan') ||
        normalized.contains('user') ||
        normalized.contains('email') ||
        normalized.contains('nomor');
    final passwordError =
        normalized.contains('password') ||
        normalized.contains('sandi') ||
        normalized.contains('salah');
    final identifierError = looksLikeIdentifierError && !passwordError;
    setState(() {
      _isNavigating = false;
      _identifierError = identifierError ? message : null;
      _passwordError = passwordError ? message : null;
    });
    if (identifierError || passwordError) {
      _formKey.currentState?.validate();
    } else {
      AppSnackbar.show(context, message: message, type: AppSnackbarType.error);
    }
  }

  void _onGoogleLoginPressed() {
    if (_isNavigating || context.read<AuthBloc>().state is AuthLoading) {
      return;
    }
    setState(() {
      _isGoogleSubmitting = true;
      _isAppleSubmitting = false;
    });
    context.read<AuthBloc>().add(const LoginWithGoogleEvent());
  }

  void _onAppleLoginPressed() {
    if (_isNavigating || context.read<AuthBloc>().state is AuthLoading) {
      return;
    }
    if (!Platform.isIOS) {
      AppSnackbar.show(
        context,
        message:
            'Preview tombol Apple aktif. Login Apple native hanya dapat '
            'dijalankan di perangkat atau simulator iOS.',
        type: AppSnackbarType.info,
      );
      return;
    }
    setState(() {
      _isAppleSubmitting = true;
      _isGoogleSubmitting = false;
    });
    context.read<AuthBloc>().add(const LoginWithAppleEvent());
  }

  void _openSocialCompletion(SocialRegistrationRequired state) {
    if (_isNavigating) return;
    _isNavigating = true;
    FocusScope.of(context).unfocus();
    context.pushNamed('social-account-completion', extra: state).then((_) {
      if (!mounted) return;
      setState(() {
        _isNavigating = false;
        _isGoogleSubmitting = false;
        _isAppleSubmitting = false;
      });
    });
  }

  void _completeLogin(AuthState state) {
    if (_isNavigating) return;
    final user = switch (state) {
      LoginSuccess(:final user) => user,
      LoginWithGoogleSuccess(:final user) => user,
      LoginWithAppleSuccess(:final user) => user,
      _ => null,
    };
    if (user == null) return;
    _isNavigating = true;
    TextInput.finishAutofillContext(shouldSave: true);
    context.read<AuthSessionCubit>().login(user);
    AppSnackbar.show(
      context,
      message: 'Selamat datang, ${user.fullName}!',
      type: AppSnackbarType.success,
    );

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  // ================================
  // MAIN BUILD
  // ================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 360;
    final sheetHorizontalPadding = isSmallScreen ? 20.0 : 24.0;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginError) {
          _handleLoginError(state.message);
        } else if (state is LoginSuccess ||
            state is LoginWithGoogleSuccess ||
            state is LoginWithAppleSuccess) {
          _completeLogin(state);
        } else if (state is SocialRegistrationRequired) {
          _openSocialCompletion(state);
        } else if (state is LoginWithGoogleError) {
          _isNavigating = false;
          _isGoogleSubmitting = false;
          AppSnackbar.show(
            context,
            message: state.message,
            type: AppSnackbarType.error,
          );
        } else if (state is LoginWithAppleError) {
          _isNavigating = false;
          _isAppleSubmitting = false;
          AppSnackbar.show(
            context,
            message: state.message,
            type: AppSnackbarType.error,
          );
        } else if (state is AuthInitial) {
          if (_isGoogleSubmitting || _isAppleSubmitting) {
            setState(() {
              _isGoogleSubmitting = false;
              _isAppleSubmitting = false;
            });
          }
        }
      },
      child: Stack(
        children: [
          // ================================
          // PAGE CONTENT
          // ================================
          CustomHeaderScaffold(
            title: 'Masuk',
            titleWidget: const _LoginHeaderTitle(),
            showBackButton: false,
            backgroundColor: const Color(0xFFF6F7F9),
            headerHeight: 270,
            contentTop: 232,
            resizeToAvoidBottomInset: true,
            bodyPadding: EdgeInsets.zero,
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        sheetHorizontalPadding,
                        28,
                        sheetHorizontalPadding,
                        28,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(36),
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: AutofillGroup(
                            onDisposeAction: AutofillContextAction.cancel,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                      height: 1.2,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildIdentifierField(),
                                  const SizedBox(height: 16),
                                  _buildPasswordField(),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isNavigating
                                          ? null
                                          : () => context.pushNamed(
                                              'forgot-password-phone',
                                            ),
                                      style: _linkStyle(),
                                      child: const Text('Lupa password?'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildLoginButton(),
                                  const SizedBox(height: 20),
                                  const _LoginDivider(),
                                  const SizedBox(height: 16),
                                  _buildSocialButtons(),
                                  const SizedBox(height: 20),
                                  _buildRegisterLink(),
                                  // const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ================================
          // CLOSE BUTTON
          // ================================
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              left: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 20),
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: _closeLogin,
                    tooltip: 'Tutup',
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0x33FFFFFF),
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(
                        side: BorderSide(color: Color(0x4DFFFFFF)),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // LINK STYLE
  // ================================

  ButtonStyle _linkStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      minimumSize: const Size(44, 36),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ================================
  // IDENTIFIER FIELD
  // ================================

  Widget _buildIdentifierField() {
    return _LoginField(
      controller: _identifierController,
      hint: 'Nomor HP, email, atau username',
      prefixIcon: Icons.person_rounded,
      autofillHints: const [AutofillHints.username],
      textInputAction: TextInputAction.next,
      validator: _validateIdentifier,
      onChanged: (_) {
        _clearError(identifier: true);
      },
    );
  }

  // ================================
  // PASSWORD FIELD
  // ================================

  Widget _buildPasswordField() {
    return _LoginField(
      controller: _passwordController,
      hint: 'Password',
      prefixIcon: Icons.lock_rounded,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      validator: _validatePassword,
      obscureText: !_isPasswordVisible,
      onChanged: (_) {
        _clearError(identifier: false);
      },
      onFieldSubmitted: (_) {
        _onLoginPressed();
      },
      suffixIcon: IconButton(
        tooltip: _isPasswordVisible ? 'Sembunyikan password' : 'Lihat password',
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFF94A3B8),
          size: 19,
        ),
      ),
    );
  }

  // ================================
  // LOGIN BUTTON
  // ================================

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading =
            state is AuthLoading &&
            state.operation == AuthOperation.manualLogin;
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: state is AuthLoading || _isNavigating
                ? null
                : _onLoginPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFFECACA),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Masuk'),
          ),
        );
      },
    );
  }

  // ================================
  // GOOGLE LOGIN
  // ================================

  Widget _buildGoogleButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading =
            state is AuthLoading &&
            state.operation == AuthOperation.googleLogin;
        final disabled = state is AuthLoading || _isNavigating;
        return Center(
          child: Tooltip(
            message: 'Masuk dengan Google',
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              elevation: 0,
              child: Ink(
                width: 56,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  key: const Key('google-sign-in-button'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: disabled ? null : _onGoogleLoginPressed,
                  child: Center(
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          )
                        : Image.asset(
                            'assets/icons/google.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 26,
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButtons() {
    final showApple =
        Platform.isIOS || (kDebugMode && _showApplePreviewOnAndroid);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGoogleButton(),
        if (showApple) ...[const SizedBox(width: 12), _buildAppleButton()],
      ],
    );
  }

  Widget _buildAppleButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading =
            state is AuthLoading && state.operation == AuthOperation.appleLogin;
        final disabled = state is AuthLoading || _isNavigating;
        return Tooltip(
          message: 'Masuk dengan Apple',
          child: Material(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              width: 56,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                key: const Key('apple-sign-in-button'),
                borderRadius: BorderRadius.circular(10),
                onTap: disabled ? null : _onAppleLoginPressed,
                child: Center(
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.apple, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================================
  // REGISTER LINK
  // ================================

  Widget _buildRegisterLink() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Belum punya akun?',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          TextButton(
            onPressed: _isNavigating ? null : () => context.push('/register'),
            style: _linkStyle(),
            child: const Text('Daftar sekarang'),
          ),
        ],
      ),
    );
  }
}

// ========================================
// HEADER TITLE
// ========================================

class _LoginHeaderTitle extends StatelessWidget {
  const _LoginHeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo dibungkus badge putih supaya warna merah-kuningnya
        // tidak tenggelam di header merah.
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icons/icon_app.png',
            fit: BoxFit.contain,
            semanticLabel: 'Logo EKAPLUS',
            errorBuilder: (_, __, ___) => const Icon(
              Icons.storefront_rounded,
              color: Color(0xFFB91C1C),
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Halo!',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Selamat datang di EKAPLUS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xE6FFFFFF),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ========================================
// CUSTOM LOGIN FIELD
// ========================================

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.autofillHints,
    required this.textInputAction,
    required this.validator,
    required this.onChanged,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Iterable<String> autofillHints;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        // Border tipis saat idle supaya field tidak "hilang" di bg abu terang.
        border: _border(const Color(0xFFE2E8F0)),
        enabledBorder: _border(const Color(0xFFE2E8F0)),
        focusedBorder: _border(AppColors.primaryColor, width: 1.5),
        errorBorder: _border(AppColors.primaryColor),
        focusedErrorBorder: _border(AppColors.primaryColor, width: 1.5),
        errorStyle: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: AppColors.primaryColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

// ========================================
// LOGIN DIVIDER
// ========================================
class _LoginDivider extends StatelessWidget {
  const _LoginDivider();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFCBD5E1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Atau masuk dengan',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFCBD5E1))),
      ],
    );
  }
}
