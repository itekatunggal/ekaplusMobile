// lib/features/member/presentation/widgets/supporting_data_section_widget.dart

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import '../utils/member_registration_form_state.dart';

/// Widget untuk section data pendukung
class SupportingDataSectionWidget extends StatelessWidget {
  final MemberRegistrationFormState formState;
  final String? contactPersonError;
  final String? emailCompanyError;
  final String? factoryAddressError;
  final String? faxError;

  const SupportingDataSectionWidget({
    super.key,
    required this.formState,
    this.contactPersonError,
    this.emailCompanyError,
    this.factoryAddressError,
    this.faxError,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: AppColors.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            const Text(
              'Data Pendukung',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Contact Person
            _buildTextField(
              label: 'Contact Person (Opsional)',
              controller: formState.contactPersonController,
              textCapitalization: TextCapitalization.words,
              icon: Icons.contact_phone_outlined,
              errorText: contactPersonError,
            ),
            const SizedBox(height: 16),

            // Email Perusahaan
            _buildTextField(
              label: 'Email Perusahaan (Opsional)',
              controller: formState.emailCompanyController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: emailCompanyError,
            ),
            const SizedBox(height: 16),

            // Fax (Optional)
            _buildTextField(
              label: 'Fax (Opsional)',
              controller: formState.faxController,
              icon: Icons.fax_outlined,
              errorText: faxError,
            ),
            const SizedBox(height: 16),

            // Alamat Pabrik (Optional)
            _buildTextField(
              label: 'Alamat Pabrik (Opsional)',
              controller: formState.factoryAddressController,
              textCapitalization: TextCapitalization.sentences,
              icon: Icons.factory_outlined,
              maxLines: 3,
              errorText: factoryAddressError,
            ),

            // Info text
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_outlined,
                      size: 20, color: Colors.purple[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan data contact person dan email perusahaan aktif untuk komunikasi lebih lanjut',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    textCapitalization,
    TextInputType? keyboardType,
    int? maxLines,
    String? errorText,
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
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
