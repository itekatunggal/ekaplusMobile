// lib/features/auth/presentation/widgets/password_section_widget.dart

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';

/// Widget untuk section password (password dan confirm password dengan requirements)
class PasswordSectionWidget extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final Function() onTogglePassword;
  final Function() onToggleConfirmPassword;
  final String? Function(String?)? validatePassword;
  final String? Function(String?)? validateConfirmPassword;

  const PasswordSectionWidget({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.validatePassword,
    this.validateConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      color: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFF1F5F9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            const Text(
              'Keamanan Akun',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            _buildPasswordField(
              controller: passwordController,
              label: 'Kata Sandi',
              hint: 'Masukkan kata sandi',
              obscureText: obscurePassword,
              onToggle: onTogglePassword,
              validator: validatePassword,
              showRequirements: true,
            ),
            const SizedBox(height: 12),

            _buildPasswordField(
              controller: confirmPasswordController,
              label: 'Konfirmasi Kata Sandi',
              hint: 'Masukkan ulang kata sandi',
              obscureText: obscureConfirmPassword,
              onToggle: onToggleConfirmPassword,
              validator: validateConfirmPassword,
              showRequirements: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    required bool showRequirements,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 10.5,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
            fontFamily: AppFonts.primaryFont,
            fontSize: 12,
          ),
        ),
        if (showRequirements)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPasswordRequirement(
                  'Minimal 6 karakter',
                  controller.text.length >= 6,
                ),
                const SizedBox(height: 4),
                _buildPasswordRequirement(
                  'Mengandung angka atau simbol',
                  controller.text.contains(
                    RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isValid ? Colors.green : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
