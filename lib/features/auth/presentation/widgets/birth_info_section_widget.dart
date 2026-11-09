import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';

class BirthInfoSectionWidget extends StatelessWidget {
  const BirthInfoSectionWidget({
    super.key,
    required this.birthPlaceController,
    required this.birthDateController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onSelectBirthDate,
    this.validateRequired,
  });

  final TextEditingController birthPlaceController;
  final TextEditingController birthDateController;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onSelectBirthDate;
  final String? Function(String?, String)? validateRequired;

  static const _fieldFill = Color(0xFFF8FAFC);
  static const _fieldBorder = Color(0xFFE2E8F0);

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
            const Text(
              'Informasi Kelahiran',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            _buildGenderDropdown(),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final place = _buildTextField(
                  controller: birthPlaceController,
                  label: 'Tempat Lahir',
                  hint: 'Masukkan tempat lahir',
                  icon: Icons.location_on_outlined,
                  validator: (value) =>
                      validateRequired?.call(value, 'Tempat lahir'),
                );
                final date = _buildDateField();
                if (constraints.maxWidth >= 440) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: place),
                      const SizedBox(width: 12),
                      Expanded(child: date),
                    ],
                  );
                }
                return Column(
                  children: [place, const SizedBox(height: 14), date],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return _FieldShell(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        textCapitalization: TextCapitalization.words,
        style: _textStyle,
        decoration: _decoration(hint: hint, icon: icon),
      ),
    );
  }

  Widget _buildDateField() {
    return _FieldShell(
      label: 'Tanggal Lahir',
      child: TextFormField(
        controller: birthDateController,
        readOnly: true,
        onTap: onSelectBirthDate,
        validator: (value) => validateRequired?.call(value, 'Tanggal lahir'),
        style: _textStyle,
        decoration: _decoration(
          hint: 'Pilih tanggal lahir',
          icon: Icons.calendar_today_outlined,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return _FieldShell(
      label: 'Jenis Kelamin',
      child: DropdownButtonFormField<String>(
        initialValue: selectedGender,
        isExpanded: true,
        menuMaxHeight: 220,
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Colors.white,
        style: _textStyle,
        decoration: _decoration(
          hint: 'Pilih jenis kelamin',
          icon: Icons.wc_outlined,
        ),
        items: const [
          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ],
        onChanged: onGenderChanged,
        validator: (value) =>
            value == null ? 'Jenis kelamin tidak boleh kosong' : null,
      ),
    );
  }

  TextStyle get _textStyle => const TextStyle(
    fontFamily: AppFonts.primaryFont,
    color: Color(0xFF0F172A),
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  InputDecoration _decoration({required String hint, required IconData icon}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      prefixIcon: Icon(icon, size: 19, color: const Color(0xFF64748B)),
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 11,
        color: Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: _fieldFill,
      border: border(_fieldBorder),
      enabledBorder: border(_fieldBorder),
      focusedBorder: border(AppColors.primaryColor, 1.4),
      errorBorder: border(AppColors.primaryColor, 1.2),
      focusedErrorBorder: border(AppColors.primaryColor, 1.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}
