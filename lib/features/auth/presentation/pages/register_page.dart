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
    AppSnackbar.showRaw(context, snackBar);
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

  void _closeRegister() {
    if (_isNavigating) return;
    FocusScope.of(context).unfocus();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 360;
    final sheetHorizontalPadding = screenWidth >= 600
        ? 24.0
        : isSmallScreen
        ? 16.0
        : 20.0;
    final isIOS = io.Platform.isIOS;

    return BlocListener<AuthBloc, AuthState>(
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
            'Kode verifikasi 6 digit telah dikirim ke WhatsApp Anda',
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
        } else if (state is LoginWithGoogleSuccess ||
            state is LoginWithAppleSuccess) {
          if (_isNavigating) return;
          _isNavigating = true;

          FocusScope.of(context).unfocus();
          final user = switch (state) {
            LoginWithGoogleSuccess(:final user) => user,
            LoginWithAppleSuccess(:final user) => user,
            _ => throw StateError('State login sosial tidak didukung'),
          };
          context.read<AuthSessionCubit>().login(user);

          _showSuccessSnackBar('Selamat datang, ${user.fullName}!');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.go('/');
          });
        } else if (state is SocialRegistrationRequired) {
          if (_isNavigating) return;
          _isNavigating = true;
          FocusScope.of(context).unfocus();
          context.pushNamed('social-account-completion', extra: state).then((
            _,
          ) {
            if (!mounted) return;
            setState(() => _isNavigating = false);
          });
        } else if (state is LoginWithGoogleError ||
            state is LoginWithAppleError) {
          setState(() {
            _isNavigating = false;
          });
          final message = switch (state) {
            LoginWithGoogleError(:final message) => message,
            LoginWithAppleError(:final message) => message,
            _ => 'Login sosial gagal. Silakan coba lagi.',
          };
          _showErrorSnackBar(message);
        }
      },
      child: CustomHeaderScaffold(
        title: 'Buat akun baru',
        subtitle:
            'Lihat daftar katalog Ekatunggal dan rincian pembelian produk.',
        showBackButton: false,
        headerHeight: 200,
        contentTop: 150,
        backgroundColor: const Color(0xFFF6F7F9),
        bodyPadding: EdgeInsets.zero,
        resizeToAvoidBottomInset: true,
        actions: [
          CustomHeaderActionButton(
            tooltip: 'Tutup',
            onPressed: _closeRegister,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    sheetHorizontalPadding,
                    20,
                    sheetHorizontalPadding,
                    32,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(18),
                                ),
                                border: Border.fromBorderSide(
                                  BorderSide(
                                    color: Color(0xFFF1F5F9),
                                    width: 1,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x120F172A),
                                    blurRadius: 20,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _RegistrationStepBadge(),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Daftar dengan nomor WhatsApp',
                                    style: TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                      height: 1.25,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Kami akan mengirim kode verifikasi untuk memastikan nomor ini milik Anda.',
                                    style: TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Nomor WhatsApp',
                                    style: TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPhoneInput(isSmallScreen, isIOS),
                                  const SizedBox(height: 10),
                                  _buildHelperText(isSmallScreen, isIOS),
                                  const SizedBox(height: 20),
                                  _buildRegisterButton(isSmallScreen, isIOS),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDivider(isSmallScreen, isIOS),
                            const SizedBox(height: 14),
                            _buildSocialButtons(isIOS),
                            const SizedBox(height: 16),
                            _buildLoginLink(isSmallScreen, isIOS),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Dengan mendaftar, Anda menyetujui ketentuan dan kebijakan privasi EKAPLUS.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppFonts.primaryFont,
                                  fontSize: 9.5,
                                  color: Color(0xFF94A3B8),
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
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
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.telephoneNumber],
        onFieldSubmitted: (_) => _onNextPressed(),
        style: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13),
        ],
        decoration: InputDecoration(
          hintText: 'Contoh: 0812 3456 7890',
          hintStyle: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Container(
              width: 38,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasError
                    ? const Color(0xFFFFF1F2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ID',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: hasError
                      ? AppColors.primaryColor
                      : const Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 62),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.only(top: 13, right: 14, bottom: 13),
          border: _phoneBorder(const Color(0xFFE2E8F0)),
          enabledBorder: _phoneBorder(const Color(0xFFE2E8F0)),
          focusedBorder: _phoneBorder(AppColors.primaryColor, width: 1.5),
          errorBorder: _phoneBorder(AppColors.primaryColor),
          focusedErrorBorder: _phoneBorder(AppColors.primaryColor, width: 1.5),
          errorStyle: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: AppColors.primaryColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        validator: _validatePhone,
        onChanged: (value) {
          if (_phoneErrorMessage != null) {
            setState(() => _phoneErrorMessage = null);
            _formKey.currentState?.validate();
          }
        },
      ),
    );
  }

  OutlineInputBorder _phoneBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildHelperText(bool isSmallScreen, bool isIOS) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: Color(0xFF64748B),
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Nomor Anda aman dan hanya digunakan untuk verifikasi akun.',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 10.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isSmallScreen, bool isIOS) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFF1F5F9))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau lanjutkan dengan',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 10.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFF1F5F9))),
      ],
    );
  }

  Widget _buildGoogleButton({required bool compact}) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading =
            state is AuthLoading &&
            state.operation == AuthOperation.googleLogin;
        final disabled = state is AuthLoading || _isNavigating;
        return SizedBox(
          width: compact ? 56 : double.infinity,
          child: Tooltip(
            message: 'Daftar dengan Google',
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: InkWell(
                  key: const Key('register-google-button'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: disabled
                      ? null
                      : () => context.read<AuthBloc>().add(
                          const LoginWithGoogleEvent(),
                        ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/google.png',
                                width: compact ? 24 : 21,
                                height: compact ? 24 : 21,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.g_mobiledata_rounded,
                                  size: compact ? 26 : 25,
                                ),
                              ),
                              if (!compact) ...[
                                const SizedBox(width: 10),
                                const Text(
                                  'Daftar dengan Google',
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ],
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

  Widget _buildSocialButtons(bool isIOS) {
    if (!isIOS) {
      return _buildGoogleButton(compact: false);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGoogleButton(compact: true),
        const SizedBox(width: 12),
        _buildAppleButton(),
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
          message: 'Daftar dengan Apple',
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
                key: const Key('register-apple-button'),
                borderRadius: BorderRadius.circular(10),
                onTap: disabled
                    ? null
                    : () => context.read<AuthBloc>().add(
                        const LoginWithAppleEvent(),
                      ),
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

  Widget _buildRegisterButton(bool isSmallScreen, bool isIOS) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (isLoading || _isNavigating) ? null : _onNextPressed,
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
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Kirim Kode Verifikasi'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink(bool isSmallScreen, bool isIOS) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Sudah punya akun?',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
          TextButton(
            onPressed: _isNavigating ? null : () => context.push('/login'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              minimumSize: const Size(44, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Masuk sekarang'),
          ),
        ],
      ),
    );
  }
}

class _RegistrationStepBadge extends StatelessWidget {
  const _RegistrationStepBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 6),
          Text(
            'LANGKAH 1 · VERIFIKASI NOMOR',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.45,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
