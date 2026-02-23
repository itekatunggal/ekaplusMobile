// lib/features/member/presentation/widgets/member_confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../constant.dart';

class MemberConfirmationDialog extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onConfirm;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final String title;
  final String description;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final bool showSectionEditAction;
  final bool showPrimarySendIcon;

  const MemberConfirmationDialog({
    super.key,
    required this.formData,
    required this.onConfirm,
    required this.onClose,
    this.onEdit,
    this.title = 'Konfirmasi Data',
    this.description =
        'Pastikan seluruh data yang Anda masukkan sudah benar sebelum mengirim formulir pendaftaran.',
    this.primaryButtonText = 'Yakin, Kirim Formulir',
    this.secondaryButtonText = 'Perbaiki Data',
    this.showSectionEditAction = true,
    this.showPrimarySendIcon = true,
  });

  @override
  State<MemberConfirmationDialog> createState() =>
      _MemberConfirmationDialogState();
}

class _MemberConfirmationDialogState extends State<MemberConfirmationDialog> {
  bool _isShippingExpanded = false;

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  String? _value(List<String> keys) {
    for (final key in keys) {
      final str = _asString(widget.formData[key]);
      if (str != null) return str;
    }
    return null;
  }

  String? _branchDisplayValue() {
    final branchName = _asString(widget.formData['branch_name'])?.trim();
    final branchArea = _asString(widget.formData['branch_area'])?.trim();
    final branchId = _asString(widget.formData['branch_id'])?.trim();

    if (branchName != null && branchName.isNotEmpty) {
      if (branchArea != null && branchArea.isNotEmpty) {
        return '$branchName - $branchArea';
      }
      return branchName;
    }

    return branchId;
  }

  String _displayBirthDate() {
    final raw = _asString(widget.formData['owner_date_of_birth'])?.trim() ?? '';
    if (raw.isEmpty) return '';

    try {
      final date = DateTime.parse(raw);
      final d = date.toLocal();
      return DateFormat('dd MMM yyyy', 'id_ID').format(d);
    } catch (_) {}

    final parts = raw.split('-');
    if (parts.length >= 3) {
      final y = parts[0];
      final m = parts[1];
      final d = parts[2].split('T').first;
      if (y.length == 4) {
        try {
          final parsed = DateTime.parse('$y-$m-$d');
          return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
        } catch (_) {
          return '$d-$m-$y';
        }
      }
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: widget.onClose,
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    const Text(
                      'Tinjau Aplikasi Anda',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Data Identitas Section
                    _buildIdentitySection(),
                    const SizedBox(height: 32),

                    // Informasi Perusahaan Section
                    _buildCompanySection(),
                    const SizedBox(height: 32),

                    // Alamat Section
                    _buildAddressSection(),

                    // Alamat Pengiriman Section
                    _buildShippingAddressSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Footer Buttons
            _buildFooterButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataItem({
    required String label,
    required String? value,
    bool isItalicEmpty = true,
  }) {
    final displayValue = value?.isNotEmpty == true ? value! : '—';
    final isEmpty = value?.isEmpty ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayValue,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isEmpty && isItalicEmpty ? Colors.grey[500] : Colors.black87,
            fontStyle: isEmpty && isItalicEmpty
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.person,
          title: 'Data Identitas',
          onEdit: widget.showSectionEditAction ? widget.onEdit : null,
        ),
        _buildDataItem(
          label: 'Nama Lengkap',
          value: widget.formData['owner_full_name'],
        ),
        _buildDivider(),
        _buildDataItem(label: 'Email', value: widget.formData['owner_email']),
        _buildDivider(),
        _buildDataItem(label: 'Telepon', value: widget.formData['owner_phone']),
        _buildDivider(),
        Row(
          children: [
            Expanded(
              child: _buildDataItem(
                label: 'Tempat Lahir',
                value: widget.formData['owner_place_of_birth'],
              ),
            ),
            Expanded(
              child: _buildDataItem(
                label: 'Tanggal Lahir',
                value: _displayBirthDate(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.business,
          title: 'Informasi Perusahaan',
          onEdit: widget.showSectionEditAction ? widget.onEdit : null,
        ),
        // Kebutuhan Produk with chips
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KEBUTUHAN PRODUK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            _buildProductChips(widget.formData['product_need']),
          ],
        ),
        _buildDivider(),
        _buildDataItem(label: 'Cabang', value: _branchDisplayValue()),
        _buildDivider(),
        _buildDataItem(
          label: 'Jenis Perusahaan',
          value: widget.formData['company_type'],
        ),
        _buildDivider(),
        _buildDataItem(
          label: 'Gelar Perusahaan',
          value: widget.formData['company_title'],
        ),
        _buildDivider(),
        _buildDataItem(
          label: 'Nama Perusahaan',
          value: widget.formData['company_name'],
        ),
        // _buildDivider(),
        // _buildPKPStatus(widget.formData['is_pkp'] == true),
      ],
    );
  }

  // Widget _buildPKPStatus(bool isPKP) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'STATUS PKP',
  //         style: TextStyle(
  //           fontSize: 11,
  //           fontWeight: FontWeight.w500,
  //           color: Colors.grey[500],
  //           letterSpacing: 0.5,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //         decoration: BoxDecoration(
  //           color: isPKP
  //               ? Colors.green.withValues(alpha: 0.1)
  //               : Colors.grey[100],
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(
  //               isPKP ? Icons.check_circle : Icons.cancel,
  //               size: 16,
  //               color: isPKP ? Colors.green[700] : Colors.grey[600],
  //             ),
  //             const SizedBox(width: 6),
  //             Text(
  //               isPKP ? 'Terdaftar PKP' : 'Bukan PKP',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //                 color: isPKP ? Colors.green[700] : Colors.grey[600],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildProductChips(String? productNeed) {
    if (productNeed == null || productNeed.isEmpty) {
      return Text(
        '— Belum dipilih',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            productNeed,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.place,
          title: 'Alamat',
          onEdit: widget.showSectionEditAction ? widget.onEdit : null,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataItem(
                label: 'Alamat Lengkap',
                value: _value(['company_address', 'address']),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDataItem(
                      label: 'Kecamatan',
                      value: _value(['company_district', 'district']),
                    ),
                  ),
                  Expanded(
                    child: _buildDataItem(
                      label: 'Kota/Kabupaten',
                      value: _value(['company_city', 'city']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDataItem(
                      label: 'Provinsi',
                      value: _value(['company_province', 'province']),
                    ),
                  ),
                  Expanded(
                    child: _buildDataItem(
                      label: 'Kode Pos',
                      value: _value(['company_postal_code', 'postal_code']),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingAddressSection() {
    final shippingAddresses =
        (widget.formData['customer_shipping_address'] ??
                widget.formData['shipping_addresses'])
            as List<dynamic>?;
    final count = shippingAddresses?.length ?? 0;

    if (count == 0) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // Header - tap to expand
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isShippingExpanded = !_isShippingExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alamat Pengiriman ($count)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      _isShippingExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.chevron_right,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ),

              // Expanded content
              if (_isShippingExpanded) ...[
                const SizedBox(height: 16),
                ...shippingAddresses!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final address = entry.value as Map<String, dynamic>;
                  return _buildShippingAddressCard(index, address);
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingAddressCard(int index, Map<String, dynamic> address) {
    final isSameAsCompany =
        address['same_as_company'] == true ||
        address['same_as_company_address'] == true ||
        address['same_as_company_address'] == 1;
    final isDefault = address['is_default'] == true || address['is_default'] == 1;

    return Container(
      margin: EdgeInsets.only(top: index > 0 ? 12 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _asString(address['label'])?.trim().isNotEmpty == true
                    ? _asString(address['label'])!
                    : 'Alamat ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              if (isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
              if (isSameAsCompany) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sama dengan Perusahaan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  label: 'PIC',
                  value: _asString(address['pic_name']),
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  label: 'No HP PIC',
                  value: _asString(address['pic_phone']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDataItem(label: 'Alamat', value: address['address']),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  label: 'Kecamatan',
                  value: address['district'],
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  label: 'Kota/Kab',
                  value: address['city'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  label: 'Provinsi',
                  value: address['province'],
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  label: 'Kode Pos',
                  value: address['postal_code'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(
            builder: (_) {
              final child = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.primaryButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.showPrimarySendIcon) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.send, size: 18),
                  ],
                ],
              );

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: child,
                ),
              );
            },
          ),
          if (widget.onEdit != null && widget.secondaryButtonText != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onEdit,
              child: Text(
                widget.secondaryButtonText!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
