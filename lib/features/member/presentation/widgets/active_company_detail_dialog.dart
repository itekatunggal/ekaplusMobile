import 'package:flutter/material.dart';

import '../../../../constant.dart';
import '../../../../core/shared_widgets/custom_header.dart';
import '../../domain/entities/active_member_company.dart';

class ActiveCompanyDetailDialog extends StatelessWidget {
  final ActiveMemberCompany company;
  final List<Map<String, dynamic>> shippingAddresses;
  final bool isActiveSelected;
  final Future<void> Function()? onSetActive;
  final VoidCallback onClose;

  const ActiveCompanyDetailDialog({
    super.key,
    required this.company,
    this.shippingAddresses = const [],
    this.isActiveSelected = false,
    this.onSetActive,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final gcName = (company.gcName ?? '').trim();
    final customerCompanyName = (company.customerCompanyName ?? '').trim();
    final companyName = gcName.isNotEmpty
        ? gcName
        : (customerCompanyName.isEmpty
              ? company.displayName
              : customerCompanyName);
    const pageBg = Color(0xFFF6F7F9);
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: CustomHeaderAppBar(
          title: 'Detail Customer',
          // subtitle: company.bcidDisplayLabel,
          centerTitle: false,
          onBackPressed: onClose,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 10),
                      child: child,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _companySummary(
                        companyName: companyName,
                        city: company.branchCity,
                        branchName: company.branchName,
                      ),
                      const SizedBox(height: 14),
                      _section(
                        icon: Icons.person_outline_rounded,
                        title: 'Informasi Pemilik',
                        children: [
                          _itemStack('Nama Pemilik', company.customerOwnerName),
                          const SizedBox(height: 14),
                          _itemStack('Email', company.customerOwnerEmail),
                          const SizedBox(height: 14),
                          _itemStack('No. HP', company.customerOwnerPhone),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _section(
                        icon: Icons.apartment_rounded,
                        title: 'Informasi Perusahaan',
                        children: [
                          _itemStack('Nama Perusahaan', companyName),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _itemStack(
                                  'Jenis',
                                  company.customerCompanyType,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _itemStack(
                                  'Gelar',
                                  company.customerCompanyTitle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _itemStack('Kebutuhan', company.customerProductNeed),
                          const SizedBox(height: 14),
                          _itemStack(
                            'Status Perpajakan',
                            company.customerTaxStatus ? 'PKP' : 'NON PKP',
                          ),
                          const SizedBox(height: 14),
                          _itemStack(
                            'Alamat Perusahaan',
                            _joinAddress([
                              company.customerCompanyAddress,
                              company.customerCompanyDistrict,
                              company.customerCompanyCity,
                              company.customerCompanyProvince,
                              company.customerCompanyPostalCode,
                            ]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      _section(
                        icon: Icons.storefront_outlined,
                        title: 'Informasi Cabang',
                        children: [
                          _itemStack('Nama Perusahaan', companyName),
                          const SizedBox(height: 14),
                          _itemStack('Cabang Terdekat', company.branchName),
                          const SizedBox(height: 14),
                          _itemStack('Kota', company.branchCity),
                          const SizedBox(height: 14),
                          _itemStack(
                            'Nama PIC Branch',
                            company.branchOwnerName,
                          ),
                          const SizedBox(height: 14),
                          _itemStack(
                            'Nomor PIC Branch',
                            company.branchOwnerPhone,
                          ),
                          const SizedBox(height: 14),
                          _itemStack(
                            'Email PIC Branch',
                            company.branchOwnerEmail,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _section(
                        icon: Icons.local_shipping_outlined,
                        title: 'Alamat Pengiriman',
                        children: _buildShippingAddressChildren(),
                      ),
                      const SizedBox(height: 84),
                    ],
                  ),
                ),
              ),
            ),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final canSetActive = !isActiveSelected && onSetActive != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Row(
          children: [
            if (canSetActive) ...[
              Expanded(child: _SetActiveButton(onSetActive: onSetActive!)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: OutlinedButton(
                onPressed: onClose,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Selesai',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _companySummary({
    required String companyName,
    required String? city,
    required String? branchName,
  }) {
    final cityLabel = (city ?? '').trim();
    final branchLabel = (branchName ?? '').trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActiveSelected
              ? const Color(0xFF10B981)
              : const Color(0xFFE2E8F0),
          width: isActiveSelected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (isActiveSelected)
            Container(
              width: double.infinity,
              color: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: const Row(
                children: [
                  SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'PERUSAHAAN TERPILIH SAAT INI',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x40FFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text(
                        'Aktif',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          cityLabel,
                          branchLabel,
                        ].where((value) => value.isNotEmpty).join(' • '),
                        style: const TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF059669), size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ...children,
        ],
      ),
    );
  }

  Widget _itemStack(String label, String? value) {
    final v = (value ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          v.isEmpty ? '-' : v,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _item(String label, String? value) {
    final v = (value ?? '').trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.35,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _joinAddress(List<String?> parts) {
    final values = parts
        .map((e) => (e ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (values.isEmpty) return null;
    return values.join(', ');
  }

  String? _displayPhone(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62') && digits.length > 2) {
      return '0${digits.substring(2)}';
    }
    if (digits.startsWith('0')) return digits;
    if (raw.startsWith('+62') && digits.length > 2) {
      return '0${digits.substring(2)}';
    }
    return raw;
  }

  List<Widget> _buildShippingAddressChildren() {
    if (shippingAddresses.isEmpty) {
      return [_itemStack('Data', '-')];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < shippingAddresses.length; i++) {
      final row = shippingAddresses[i];
      final label = (row['label'] ?? '').toString().trim();
      final type = (row['type'] ?? '').toString().trim();
      final rowPicName = (row['pic_name'] ?? '').toString().trim();
      final rowPicPhone = (row['pic_phone'] ?? '').toString().trim();
      final rowPicEmail = (row['pic_email'] ?? '').toString().trim();
      final picName = rowPicName.isNotEmpty
          ? rowPicName
          : (type.toLowerCase() == 'office'
                ? (company.branchOwnerName ?? '').trim()
                : '');
      final picPhone = rowPicPhone.isNotEmpty
          ? (_displayPhone(rowPicPhone) ?? rowPicPhone)
          : (type.toLowerCase() == 'office'
                ? (_displayPhone(company.branchOwnerPhone) ?? '')
                : '');
      final picEmail = rowPicEmail.isNotEmpty
          ? rowPicEmail
          : (type.toLowerCase() == 'office'
                ? (company.branchOwnerEmail ?? '').trim()
                : '');
      final isDefault = row['is_default'] == 1 || row['is_default'] == true;
      final address = _joinAddress([
        row['address']?.toString(),
        row['district']?.toString(),
        row['city']?.toString(),
        row['province']?.toString(),
        row['postal_code']?.toString(),
        row['country']?.toString(),
      ]);

      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _itemStack(
                      'Label',
                      label.isEmpty ? 'Alamat ${i + 1}' : label,
                    ),
                  ),
                  if (type.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        'Default',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _item('PIC', picName),
              _item('No. HP PIC', picPhone),
              _item('Email PIC', picEmail),
              _item('Alamat', address),
            ],
          ),
        ),
      );

      if (i < shippingAddresses.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }

    return widgets;
  }
}

class _SetActiveButton extends StatefulWidget {
  final Future<void> Function() onSetActive;

  const _SetActiveButton({required this.onSetActive});

  @override
  State<_SetActiveButton> createState() => _SetActiveButtonState();
}

class _SetActiveButtonState extends State<_SetActiveButton> {
  bool _loading = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              await widget.onSetActive();
              if (!mounted) return;
              setState(() {
                _loading = false;
                _done = true;
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _loading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _done ? 'Perusahaan Aktif' : 'Pilih Perusahaan',
                key: ValueKey(_done ? 'done' : 'idle'),
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
