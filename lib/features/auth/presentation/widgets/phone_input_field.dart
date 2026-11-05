// lib/features/auth/presentation/widgets/personal_info_section_widget.dart

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';

class PersonalInfoSectionWidget extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController fullNameController;
  final TextEditingController usernameController;
  final String? Function(String?)? validateName;

  const PersonalInfoSectionWidget({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.fullNameController,
    required this.usernameController,
    this.validateName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: AppColors.whiteColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            const Text(
              'Informasi Personal',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            _buildResponsivePair(
              _buildTextField(
                controller: firstNameController,
                label: 'Nama Depan',
                hint: 'Masukkan nama depan',
                textCapitalization: TextCapitalization.words,
                validator: validateName,
                icon: Icons.person_outline,
              ),
              _buildTextField(
                controller: lastNameController,
                label: 'Nama Belakang',
                hint: 'Masukkan nama belakang',
                textCapitalization: TextCapitalization.words,
                validator: validateName,
                icon: Icons.person_outline,
              ),
            ),

            // Full Name (Read Only - Auto Generated)
            _buildTextField(
              controller: fullNameController,
              label: 'Nama Lengkap',
              hint: 'Otomatis terisi',
              readOnly: true,
              enabled: false,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: usernameController,
              label: 'Username',
              hint: 'Masukkan username (opsional)',
              icon: Icons.account_circle_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsivePair(Widget left, Widget right, {double spacing = 12}) {
    return LayoutBuilder(builder: (context, constraints) {
      const double breakpoint = 440;
      if (constraints.maxWidth >= breakpoint) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: spacing),
            Expanded(child: right),
          ],
        );
      } else {
        return Column(children: [left, const SizedBox(height: 12), right]);
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextCapitalization? textCapitalization,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          validator: validator,
          readOnly: readOnly,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            filled: true,
            fillColor: enabled ? AppColors.whiteColor : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

