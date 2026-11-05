// lib/features/member/presentation/widgets/identity_section_widget.dart

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import '../utils/member_registration_form_state.dart';

/// Widget untuk section identitas (sebagian read-only dari data user)
class IdentitySectionWidget extends StatelessWidget {
  final MemberRegistrationFormState formState;
  final VoidCallback onSelectBirthDate;
  final VoidCallback onStateChanged;
  final String? birthPlaceError;
  final String? dateOfBirthError;
  final String? ownerNameError;
  final String? ownerPhoneError;
  final String? ownerEmailError;
  final String? branchPicNameError;
  final String? branchPicPhoneError;
  final String? branchPicEmailError;
  final VoidCallback? onSelectBranchPicBirthDate;
  final String? branchPicDateOfBirthError;
  final bool birthFieldsReadOnly;

  const IdentitySectionWidget({
    super.key,
    required this.formState,
    required this.onSelectBirthDate,
    required this.onStateChanged,
    this.birthPlaceError,
    this.dateOfBirthError,
    this.ownerNameError,
    this.ownerPhoneError,
    this.ownerEmailError,
    this.branchPicNameError,
    this.branchPicPhoneError,
    this.branchPicEmailError,
    this.onSelectBranchPicBirthDate,
    this.branchPicDateOfBirthError,
    this.birthFieldsReadOnly = false,
  });

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
            Text(
              'Identitas User',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildReadOnlyField(
              context: context,
              label: 'Nama User',
              controller: formState.userNamaController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 8),
            _buildReadOnlyField(
              context: context,
              label: 'No. Handphone User',
              controller: formState.userPhoneController,
              icon: Icons.phone_android_outlined,
            ),
            const SizedBox(height: 8),
            _buildReadOnlyField(
              context: context,
              label: 'Email User',
              controller: formState.userEmailController,
              icon: Icons.alternate_email,
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
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

            // Nama Pemilik (Editable)
            _buildEditableField(
              context: context,
              label: 'Nama Pemilik/Pimpinan *',
              controller: formState.namaController,
              icon: Icons.badge_outlined,
              hint: 'Masukkan nama pemilik perusahaan',
              textCapitalization: TextCapitalization.characters,
              errorText: ownerNameError,
              enabled: !birthFieldsReadOnly,
            ),
            const SizedBox(height: 8),

            // Phone Pemilik (Editable)
            _buildEditableField(
              context: context,
              label: 'No. Handphone Pemilik *',
              controller: formState.phoneController,
              icon: Icons.phone_outlined,
              hint: 'Masukkan no. HP pemilik',
              keyboardType: TextInputType.phone,
              errorText: ownerPhoneError,
              enabled: !birthFieldsReadOnly,
            ),
            const SizedBox(height: 8),

            // Email Pemilik (Editable)
            _buildEditableField(
              context: context,
              label: 'Email Pemilik',
              controller: formState.emailController,
              icon: Icons.email_outlined,
              hint: 'Masukkan email pemilik',
              keyboardType: TextInputType.emailAddress,
              errorText: ownerEmailError,
              enabled: !birthFieldsReadOnly,
            ),
            const SizedBox(height: 8),

            // Tempat Lahir (Editable)
            _buildEditableField(
              context: context,
              label: 'Tempat lahir *',
              controller: formState.birthPlaceController,
              icon: Icons.location_on,
              hint: 'Masukkan tempat lahir',
              textCapitalization: TextCapitalization.characters,
              errorText: birthPlaceError,
              enabled: !birthFieldsReadOnly,
            ),
            const SizedBox(height: 8),

            // Tanggal Lahir (Editable via date picker)
            _buildDateField(context, dateOfBirthError),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Identitas PIC Branch',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: formState.branchPicSameAsOwner,
              title: const Text('Sama dengan identitas pemilik'),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                formState.branchPicSameAsOwner = val ?? false;
                if (formState.branchPicSameAsOwner) {
                  formState.syncBranchPicWithOwner();
                } else {
                  formState.clearBranchPicIdentity();
                }
                onStateChanged();
              },
            ),
            _buildEditableField(
              context: context,
              label: 'Nama PIC Branch *',
              controller: formState.branchPicNameController,
              icon: Icons.badge_outlined,
              hint: 'Masukkan nama PIC branch',
              textCapitalization: TextCapitalization.characters,
              errorText: branchPicNameError,
              enabled: !formState.branchPicSameAsOwner,
            ),
            const SizedBox(height: 8),
            _buildEditableField(
              context: context,
              label: 'Nomor PIC Branch *',
              controller: formState.branchPicPhoneController,
              icon: Icons.phone_outlined,
              hint: 'Masukkan nomor PIC branch',
              keyboardType: TextInputType.phone,
              errorText: branchPicPhoneError,
              enabled: !formState.branchPicSameAsOwner,
            ),
            const SizedBox(height: 8),
            _buildEditableField(
              context: context,
              label: 'Email PIC Branch',
              controller: formState.branchPicEmailController,
              icon: Icons.email_outlined,
              hint: 'Masukkan email PIC branch',
              keyboardType: TextInputType.emailAddress,
              errorText: branchPicEmailError,
              enabled: !formState.branchPicSameAsOwner,
            ),
            const SizedBox(height: 8),
            _buildEditableField(
              context: context,
              label: 'Tempat Lahir PIC Branch',
              controller: formState.branchPicBirthPlaceController,
              icon: Icons.location_on,
              hint: 'Masukkan tempat lahir PIC branch',
              textCapitalization: TextCapitalization.characters,
              enabled: !formState.branchPicSameAsOwner,
            ),
            const SizedBox(height: 8),
            _buildDateField(
              context,
              branchPicDateOfBirthError,
              label: 'Tanggal Lahir PIC Branch',
              controller: formState.branchPicDateOfBirthController,
              enabled: !formState.branchPicSameAsOwner,
              onTap: onSelectBranchPicBirthDate,
              respectBirthReadOnly: false,
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
                      birthFieldsReadOnly
                          ? 'Data identitas pemilik diambil dari perusahaan induk dan tidak dapat diubah pada pengajuan cabang.'
                          : 'Identitas pemilik perusahaan dapat diisi sesuai data pemilik yang sebenarnya. Identitas user adalah akun yang digunakan untuk mengajukan dan akan di-link ke data registrasi.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
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
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextCapitalization? textCapitalization,
    TextInputType? keyboardType,
    String? errorText,
    bool enabled = true,
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
          readOnly: !enabled,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String? errorText, {
    String label = 'Tanggal Lahir *',
    TextEditingController? controller,
    bool enabled = true,
    VoidCallback? onTap,
    bool respectBirthReadOnly = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller ?? formState.dateOfBirthController,
          readOnly: true,
          enabled: enabled && (!respectBirthReadOnly || !birthFieldsReadOnly),
          onTap: (enabled && (!respectBirthReadOnly || !birthFieldsReadOnly))
              ? (onTap ?? onSelectBirthDate)
              : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
            hintText: 'Pilih tanggal lahir',
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            filled: true,
            fillColor: (respectBirthReadOnly && birthFieldsReadOnly)
                ? Colors.grey[100]
                : AppColors.whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
