// lib/features/auth/presentation/pages/forgot_password_phone_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPhonePage extends StatefulWidget {
  const ForgotPasswordPhonePage({super.key});

  @override
  State<ForgotPasswordPhonePage> createState() =>
      _ForgotPasswordPhonePageState();
}

class _ForgotPasswordPhonePageState extends State<ForgotPasswordPhonePage> {
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      // agar tombol tidak ikut terdorong saat keyboard muncul
      resizeToAvoidBottomInset: false,
      appBar: const CustomHeaderAppBar(
        title: 'Lupa Password',
        subtitle: 'Masukkan nomor handphone anda',
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpRequestSuccess) {
            // OTP sent, navigate to OTP verification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kode OTP: ${state.otp}'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 5),
              ),
            );

            // Navigate to OTP page with custom headers
            context.pushNamed(
              'otp-forgot-password',
              extra: {
                'phone': _normalizePhone(_phoneController.text),
                'title': 'Atur Ulang Password',
                'subtitle': 'Kami telah mengirim kode OTP',
              },
            );
          } else if (state is PhoneNotFoundError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nomor handphone tidak terdaftar'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Hp/Username',
                    hintText: 'Masukkan nomor HP atau username',
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor handphone tidak boleh kosong';
                    }
                    if (!RegExp(r'^[0-9+]+$').hasMatch(value)) {
                      return 'Nomor handphone tidak valid';
                    }
                    if (value.length < 10) {
                      return 'Nomor handphone minimal 10 digit';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.secondaryColor,
                      disabledBackgroundColor: AppColors.secondaryColor
                          .withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.whiteColor,
                              ),
                            ),
                          )
                        : Text(
                            'Kirim Kode OTP',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                            ),
                          ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // GestureDetector(
              //   onTap: () => context.pop(),
              //   child: Text(
              //     'Kembali ke Login',
              //     style: TextStyle(
              //       fontFamily: AppFonts.primaryFont,
              //       fontSize: 14,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.primaryColor,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final normalizedPhone = _normalizePhone(_phoneController.text);

      // First check if phone exists
      context.read<AuthBloc>().add(CheckPhoneExistsEvent(normalizedPhone));

      // small delay to let bloc process - main flow uses BlocListener for outcomes
      Future.delayed(const Duration(milliseconds: 100), () {
        final state = context.read<AuthBloc>().state;

        if (state is PhoneExistsState && state.exists) {
          // Phone exists, request OTP
          context.read<AuthBloc>().add(RequestOtpEvent(normalizedPhone));
        } else if (state is PhoneNotFoundError) {
          // handled by listener
        }
      });
    }
  }

  String _normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.startsWith('0')) {
      normalized = '62${normalized.substring(1)}';
    } else if (!normalized.startsWith('62')) {
      normalized = '62$normalized';
    }
    return normalized;
  }
}
