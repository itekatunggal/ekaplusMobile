// lib/features/member/presentation/widgets/identity_section_widget.dart

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import '../utils/member_registration_form_state.dart';

/// Widget untuk section identitas (read-only fields dari data user)
class IdentitySectionWidget extends StatelessWidget {
  final MemberRegistrationFormState formState;

  const IdentitySectionWidget({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.whiteColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Text(
                  'Identitas Pemilik/Pimpinan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // const Divider(height: 24),

            // Nama (Read-only)
            _buildReadOnlyField(
              context: context,
              label: 'Nama Lengkap',
              controller: formState.namaController,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 8),

            // Phone (Read-only)
            _buildReadOnlyField(
              context: context,
              label: 'No. Handphone',
              controller: formState.phoneController,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 8),

            // Email (Read-only)
            _buildReadOnlyField(
              context: context,
              label: 'Email',
              controller: formState.emailController,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 8),

            // Tempat Lahir (Read-only)
            _buildReadOnlyField(
              context: context,
              label: 'Tempat lahir',
              controller: formState.birthPlaceController,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 8),

            // Tanggal Lahir (Read-only)
            _buildReadOnlyField(
              context: context,
              label: 'Tanggal Lahir',
              controller: formState.dateOfBirthController,
              icon: Icons.calendar_today,
            ),

            // Info text
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data ini diambil dari akun Anda dan tidak dapat diubah',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: false,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 14
          ),
        ),
      ],
    );
  }
}
