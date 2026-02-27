// lib/features/account/presentation/pages/new_password_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/change_password_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NewPasswordPage extends StatefulWidget {
  final String? userId;
  final String? phone;
  final String oldPassword;
  final String flow;

  const NewPasswordPage({
    super.key,
    this.userId,
    this.phone,
    required this.flow,
    required this.oldPassword,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      // agar tombol tidak ikut terdorong saat keyboard muncul
      resizeToAvoidBottomInset: false,
      appBar: CustomHeaderAppBar(
        title: widget.flow == 'change'
            ? 'Buat Password Baru'
            : 'Atur Ulang Password',
        subtitle: widget.flow == 'change'
            ? 'Tes'
            : 'Buat password baru untuk login ulang',
      ),
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            // Update auth session
            context.read<AuthSessionCubit>().updateUser(state.user);

            AppSnackbar.showRaw(context, 
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate based on flow
            if (widget.flow == 'change') {
              // From settings: pop back to account page
              context.pop(); // pop new password page
              context.pop(); // pop change password page
            } else {
              // From forgot password: go to login
              context.go('/login');
            }
          } else if (state is ChangePasswordError) {
            AppSnackbar.showRaw(context, 
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Password minimal 6 karakter dan mengandung 1 angka atau simbol',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // New Password Field
                Text(
                  'Password Baru',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password baru',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.grayColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password baru tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }

                    final hasDigit = value.contains(RegExp(r'[0-9]'));
                    final hasSpecialChar = value.contains(
                      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                    );

                    if (!hasDigit && !hasSpecialChar) {
                      return 'Kata sandi harus mengandung minimal 1 angka atau simbol';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password Field
                Text(
                  'Konfirmasi Password Baru',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Konfirmasi password baru',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.grayColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),

                // beri padding bawah supaya konten tidak tertutup bottomNavigationBar
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ),

      // pindahkan tombol ke bottomNavigationBar agar tidak terdorong keyboard
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                builder: (context, state) {
                  final isLoading = state is ChangePasswordLoading;

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
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.flow == 'change'
                                ? 'Ubah Password'
                                : 'Atur Ulang Password',
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
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final newPassword = _newPasswordController.text;

      if (widget.flow == 'change') {
        // Change password flow (from settings)
        context.read<ChangePasswordCubit>().updatePassword(
          userId: widget.userId!,
          newPassword: newPassword,
          oldPassword: widget.oldPassword, // verified old password
        );
      } else {
        // Reset password flow (from forgot password)
        context.read<ChangePasswordCubit>().resetPassword(
          phone: widget.phone!,
          newPassword: newPassword,
        );
      }
    }
  }
}
