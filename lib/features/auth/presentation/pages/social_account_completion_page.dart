import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/utils/social_registration_validator.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/social_auth_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SocialAccountCompletionPage extends StatefulWidget {
  final SocialRegistrationRequired registration;

  const SocialAccountCompletionPage({super.key, required this.registration});

  @override
  State<SocialAccountCompletionPage> createState() =>
      _SocialAccountCompletionPageState();
}

class _SocialAccountCompletionPageState
    extends State<SocialAccountCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late final DateTime _expiresAt;
  bool _passwordVisible = false;
  bool _confirmationVisible = false;
  bool _navigating = false;
  bool _sessionExpired = false;
  String? _usernameServerError;

  @override
  void initState() {
    super.initState();
    _expiresAt = DateTime.now().add(
      Duration(seconds: widget.registration.expiresIn),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _cancel() {
    if (_navigating) return;
    context.read<AuthBloc>().add(ResetAuthEvent());
    context.go('/');
  }

  void _backToLogin() {
    context.read<AuthBloc>().add(ResetAuthEvent());
    context.go('/login');
  }

  void _submit() {
    final state = context.read<AuthBloc>().state;
    if (_navigating || state is AuthLoading) return;
    if (DateTime.now().isAfter(_expiresAt)) {
      setState(() => _sessionExpired = true);
      return;
    }
    setState(() => _usernameServerError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      CompleteSocialRegistrationEvent(
        ticket: widget.registration.registrationToken,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _handleError(SocialRegistrationError state) {
    if (state.code == 'INVALID_REGISTRATION_TOKEN') {
      setState(() => _sessionExpired = true);
      return;
    }
    if (state.code == 'ACCOUNT_ALREADY_EXISTS' ||
        state.code == 'INVALID_INPUT') {
      setState(() => _usernameServerError = state.message);
      _formKey.currentState?.validate();
      return;
    }
    AppSnackbar.show(
      context,
      message: state.message,
      type: AppSnackbarType.error,
    );
  }

  Future<void> _completeLogin(SocialRegistrationCompleted state) async {
    if (_navigating) return;
    _navigating = true;
    await context.read<AuthSessionCubit>().login(state.user);
    if (!mounted) return;
    AppSnackbar.show(
      context,
      message: 'Akun berhasil dilengkapi. Selamat datang!',
      type: AppSnackbarType.success,
    );
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SocialRegistrationError) _handleError(state);
        if (state is SocialRegistrationCompleted) _completeLogin(state);
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _cancel();
        },
        child: CustomHeaderScaffold(
          title: 'Lengkapi Akun',
          subtitle: 'Satu langkah lagi untuk menggunakan EKAPLUS.',
          showBackButton: true,
          onBackPressed: _cancel,
          backgroundColor: const Color(0xFFF6F7F9),
          resizeToAvoidBottomInset: true,
          headerHeight: 160,
          contentTop: 124,
          bodyPadding: EdgeInsets.zero,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.sizeOf(context).width;
              final horizontalPadding = screenWidth >= 600
                  ? 24.0
                  : screenWidth < 360
                  ? 16.0
                  : 20.0;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth < 360 ? 16 : 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        border: Border.fromBorderSide(
                          BorderSide(color: Color(0xFFF1F5F9), width: 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x120F172A),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _sessionExpired ? _buildExpired() : _buildForm(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpired() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 28,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sesi pendaftaran berakhir',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Silakan masuk kembali dengan Google atau Apple untuk mendapatkan sesi baru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _backToLogin,
              style: _primaryButtonStyle(),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Kembali ke Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final email = widget.registration.prefill.email;
    final provider = widget.registration.provider == SocialProvider.apple
        ? 'Apple'
        : 'Google';
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIntroduction(provider),
            if (email != null && email.isNotEmpty) ...[
              const SizedBox(height: 20),
              const _SectionLabel('IDENTITAS TERHUBUNG'),
              const SizedBox(height: 8),
              _buildEmailBox(email, provider),
            ],
            const SizedBox(height: 20),
            const _SectionLabel('AKSES AKUN'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _usernameController,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.newUsername],
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              maxLength: 30,
              style: _inputTextStyle,
              decoration: _decoration(
                label: 'Username',
                hint: 'Contoh: budi_123',
                icon: Icons.alternate_email_rounded,
              ).copyWith(counterText: ''),
              validator: (value) =>
                  _usernameServerError ??
                  SocialRegistrationValidator.username(value),
              onChanged: (_) {
                if (_usernameServerError != null) {
                  setState(() => _usernameServerError = null);
                }
              },
            ),
            const SizedBox(height: 6),
            const Text(
              '3–30 karakter. Gunakan huruf, angka, titik, atau underscore.',
              style: _helperTextStyle,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              style: _inputTextStyle,
              decoration:
                  _decoration(
                    label: 'Password',
                    hint: 'Minimal 6 karakter',
                    icon: Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: _VisibilityButton(
                      visible: _passwordVisible,
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
              validator: SocialRegistrationValidator.password,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmationController,
              obscureText: !_confirmationVisible,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              style: _inputTextStyle,
              onFieldSubmitted: (_) => _submit(),
              decoration:
                  _decoration(
                    label: 'Konfirmasi Password',
                    hint: 'Ketik ulang password',
                    icon: Icons.lock_reset_rounded,
                  ).copyWith(
                    suffixIcon: _VisibilityButton(
                      visible: _confirmationVisible,
                      onPressed: () => setState(
                        () => _confirmationVisible = !_confirmationVisible,
                      ),
                    ),
                  ),
              validator: (value) => SocialRegistrationValidator.confirmation(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: 14),
            _buildSecurityNote(),
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading =
                    state is AuthLoading &&
                    state.operation == AuthOperation.completion;
                return SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: _primaryButtonStyle(),
                    child: loading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Selesaikan Pendaftaran'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction(String provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: AppColors.primaryColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Atur akses akun Anda',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Login $provider berhasil. Buat username dan password untuk melengkapi akun EKAPLUS.',
                style: const TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailBox(String email, String provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 18,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email $provider',
                  style: const TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.verified_rounded,
            size: 18,
            color: Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 15, color: Color(0xFFD97706)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gunakan password yang mudah Anda ingat dan jangan bagikan kepada siapa pun.',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      ),
      hintStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Color(0xFF94A3B8),
      ),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.2),
      ),
      errorStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 10,
        height: 1.3,
        color: AppColors.primaryColor,
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: const Color(0xFFFECACA),
      disabledForegroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static const _inputTextStyle = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1E293B),
  );

  static const _helperTextStyle = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: Color(0xFF94A3B8),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: Color(0xFF94A3B8),
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: .45,
        height: 1.3,
      ),
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const _VisibilityButton({required this.visible, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: visible ? 'Sembunyikan password' : 'Lihat password',
      onPressed: onPressed,
      icon: Icon(
        visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
        color: const Color(0xFF94A3B8),
      ),
    );
  }
}
