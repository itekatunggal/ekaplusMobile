import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/utils/social_registration_validator.dart';
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
          resizeToAvoidBottomInset: true,
          headerHeight: 170,
          contentTop: 126,
          bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 24),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _sessionExpired ? _buildExpired() : _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpired() {
    return Column(
      children: [
        const Icon(
          Icons.schedule_rounded,
          size: 42,
          color: AppColors.primaryColor,
        ),
        const SizedBox(height: 14),
        const Text(
          'Sesi pendaftaran berakhir. Silakan masuk dengan Google/Apple kembali.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 14),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _backToLogin,
            child: const Text('Kembali ke Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final email = widget.registration.prefill.email;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (email != null && email.isNotEmpty) ...[
            TextFormField(
              initialValue: email,
              readOnly: true,
              decoration: _decoration('Email', Icons.email_outlined),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _usernameController,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            maxLength: 30,
            decoration: _decoration('Username', Icons.person_outline),
            validator: (value) =>
                _usernameServerError ??
                SocialRegistrationValidator.username(value),
            onChanged: (_) {
              if (_usernameServerError != null) {
                setState(() => _usernameServerError = null);
              }
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            textInputAction: TextInputAction.next,
            decoration: _decoration('Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: SocialRegistrationValidator.password,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmationController,
            obscureText: !_confirmationVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: _decoration('Konfirmasi Password', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _confirmationVisible = !_confirmationVisible,
                    ),
                    icon: Icon(
                      _confirmationVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
            validator: (value) => SocialRegistrationValidator.confirmation(
              value,
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final loading =
                  state is AuthLoading &&
                  state.operation == AuthOperation.completion;
              return SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: loading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
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
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
