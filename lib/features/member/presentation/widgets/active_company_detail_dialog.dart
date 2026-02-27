import 'package:flutter/material.dart';

import '../../../../constant.dart';
import '../../domain/entities/active_member_company.dart';

class ActiveCompanyDetailDialog extends StatelessWidget {
  final ActiveMemberCompany company;
  final List<Map<String, dynamic>> shippingAddresses;
  final VoidCallback onClose;

  const ActiveCompanyDetailDialog({
    super.key,
    required this.company,
    this.shippingAddresses = const [],
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bcName = company.displayName;
    final gpName = company.gpName ?? company.gpCode ?? '-';
    final pageBg = const Color(0xFFF1F2F4);
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3F3F4),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: onClose,
          ),
          title: Text(
            bcName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2329),
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Perusahaan Aktif',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berikut adalah hierarki perusahaan aktif Anda saat ini. Pastikan data yang ditampilkan sudah sesuai.',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _section(
                      icon: Icons.grid_view_rounded,
                      title: 'Ringkasan',
                      children: [
                        _itemStack('Group Parent', gpName),
                        const SizedBox(height: 14),
                        _itemStack('Branch Customer', bcName),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _section(
                      icon: Icons.person,
                      title: 'Detail Pemilik',
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
                      icon: Icons.description_rounded,
                      title: 'Detail Perusahaan',
                      children: [
                        _itemStack(
                          'Nama Perusahaan',
                          company.customerCompanyName,
                        ),
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
                    // const SizedBox(height: 14),
                    // _section(
                    //   icon: Icons.place_outlined,
                    //   title: 'Alamat BCID',
                    //   children: [],
                    // ),
                    // const SizedBox(height: 14),
                    // _section(
                    //   icon: Icons.contacts_outlined,
                    //   title: 'Kontak BCID',
                    //   children: [],
                    // ),
                    const SizedBox(height: 14),
                    _section(
                      icon: Icons.store_outlined,
                      title: 'Alamat Pengiriman',
                      children: _buildShippingAddressChildren(),
                    ),
                    const SizedBox(height: 14),
                    _section(
                      icon: Icons.store_outlined,
                      title: 'Branch Customer',
                      children: [
                        _itemStack('BC Name', bcName),
                        const SizedBox(height: 14),
                        _itemStack('Branch Name', company.branchName),
                        const SizedBox(height: 14),
                        _itemStack('City', company.branchCity),
                        const SizedBox(height: 14),
                        _itemStack('Nama PIC Branch', company.branchOwnerName),
                        const SizedBox(height: 14),
                        _itemStack('Nomor PIC Branch', company.branchOwnerPhone),
                        const SizedBox(height: 14),
                        _itemStack('Email PIC Branch', company.branchOwnerEmail),
                      ],
                    ),
                    const SizedBox(height: 84),
                  ],
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
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
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EAEC)),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFC62828), size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          v.isEmpty ? '-' : v,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 10),
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
                fontSize: 14,
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
    if (digits.startsWith('62') && digits.length > 2) return '0${digits.substring(2)}';
    if (digits.startsWith('0')) return digits;
    if (raw.startsWith('+62') && digits.length > 2) return '0${digits.substring(2)}';
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
