// lib/features/member/presentation/widgets/member_confirmation_dialog.dart

import 'package:flutter/material.dart';
import '../../../../constant.dart';

class MemberConfirmationDialog extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const MemberConfirmationDialog({
    super.key,
    required this.formData,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  State<MemberConfirmationDialog> createState() =>
      _MemberConfirmationDialogState();
}

class _MemberConfirmationDialogState extends State<MemberConfirmationDialog> {
  bool _isShippingExpanded = false;

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
            onPressed: widget.onEdit,
          ),
          title: const Text(
            'Konfirmasi Data',
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
                      'Pastikan seluruh data yang Anda masukkan sudah benar sebelum mengirim formulir pendaftaran.',
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
            fontStyle: isEmpty && isItalicEmpty ? FontStyle.italic : FontStyle.normal,
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
          onEdit: widget.onEdit,
        ),
        _buildDataItem(
          label: 'Nama Lengkap',
          value: widget.formData['nama'],
        ),
        _buildDivider(),
        _buildDataItem(
          label: 'Email',
          value: widget.formData['email'],
        ),
        _buildDivider(),
        _buildDataItem(
          label: 'Telepon',
          value: widget.formData['phone'],
        ),
        _buildDivider(),
        Row(
          children: [
            Expanded(
              child: _buildDataItem(
                label: 'Tempat Lahir',
                value: widget.formData['birthPlace'],
              ),
            ),
            Expanded(
              child: _buildDataItem(
                label: 'Tanggal Lahir',
                value: widget.formData['dateOfBirth'],
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
          onEdit: widget.onEdit,
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
        _buildDataItem(
          label: 'Cabang',
          value: widget.formData['branch_name'],
        ),
        _buildDivider(),
        _buildDataItem(
          label: 'Jenis Perusahaan',
          value: widget.formData['entity'],
        ),
        _buildDivider(),
        _buildDataItem(
          label: 'Nama Perusahaan',
          value: widget.formData['business_name'],
        ),
        _buildDivider(),
        _buildPKPStatus(widget.formData['is_pkp'] == true),
      ],
    );
  }

  Widget _buildPKPStatus(bool isPKP) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS PKP',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPKP
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPKP ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isPKP ? Colors.green[700] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                isPKP ? 'Terdaftar PKP' : 'Bukan PKP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isPKP ? Colors.green[700] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

    // Split product need into parts if it contains "&"
    final parts = productNeed.split('&').map((e) => e.trim()).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: parts.asMap().entries.map((entry) {
        final isFirst = entry.key == 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isFirst
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            entry.value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isFirst ? AppColors.primaryColor : Colors.grey[700],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.place,
          title: 'Alamat',
          onEdit: widget.onEdit,
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
                value: widget.formData['address'],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDataItem(
                      label: 'Kode Pos',
                      value: widget.formData['postal_code'],
                    ),
                  ),
                  Expanded(
                    child: _buildDataItem(
                      label: 'Provinsi',
                      value: widget.formData['province'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDataItem(
                      label: 'Kota/Kabupaten',
                      value: widget.formData['city'],
                    ),
                  ),
                  Expanded(
                    child: _buildDataItem(
                      label: 'Kecamatan',
                      value: widget.formData['district'],
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
        widget.formData['shipping_addresses'] as List<dynamic>?;
    final count = shippingAddresses?.length ?? 0;

    if (count == 0) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
            ),
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
    final isSameAsCompany = address['same_as_company'] == true;

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
                'Alamat ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
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
          _buildDataItem(
            label: 'Alamat',
            value: address['address'],
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
                  label: 'Kecamatan',
                  value: address['district'],
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
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Button
          SizedBox(
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Yakin, Kirim Formulir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.send, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary Button
          TextButton(
            onPressed: widget.onEdit,
            child: Text(
              'Perbaiki Data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
