import 'package:flutter/material.dart';

import '../../../../constant.dart';
import '../../domain/entities/active_member_company.dart';

class ActiveCompanyDetailDialog extends StatelessWidget {
  final ActiveMemberCompany company;
  final VoidCallback onClose;

  const ActiveCompanyDetailDialog({
    super.key,
    required this.company,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bcName = company.displayName;
    final gpName = company.gpName ?? company.gpCode ?? '-';
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: onClose,
          ),
          title: const Text(
            'Detail Perusahaan Aktif',
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
                    Text(
                      'Detail Perusahaan Aktif',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berikut adalah hierarki perusahaan aktif Anda.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _section(
                      icon: Icons.apartment_outlined,
                      title: 'Ringkasan',
                      children: [
                        _item('BC Name', bcName),
                        _item('GP Name', gpName),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _section(
                      icon: Icons.description_outlined,
                      title: 'Data Pengajuan',
                      children: [
                        _item('Nama Pemilik', company.customerOwnerName),
                        _item('Email', company.customerOwnerEmail),
                        _item('No. HP', company.customerOwnerPhone),
                        _item('Nama Perusahaan', company.customerCompanyName),
                        _item('Tipe Perusahaan', company.customerCompanyType),
                        _item('Sapaan', company.customerCompanyTitle),
                        _item('Kebutuhan Produk', company.customerProductNeed),
                        _item(
                          'Alamat',
                          _joinAddress([
                            company.customerCompanyAddress,
                            company.customerCompanyDistrict,
                            company.customerCompanyCity,
                            company.customerCompanyProvince,
                            company.customerCompanyPostalCode,
                          ]),
                        ),
                        _item('Status Pengajuan', company.customerRegisterStatus),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _section(
                      icon: Icons.workspace_premium_outlined,
                      title: 'National Brand',
                      children: [
                        _item('NB Name', company.nbName),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _section(
                      icon: Icons.account_tree_outlined,
                      title: 'Group Parent',
                      children: [
                        _item('GP Name', company.gpName),
                        _item('GP Code', company.gpCode),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _section(
                      icon: Icons.groups_outlined,
                      title: 'Group Customer',
                      children: [
                        _item('GC Name', company.gcName),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _section(
                      icon: Icons.store_outlined,
                      title: 'Branch Customer',
                      children: [
                        _item('BC Name', bcName),
                        _item('BC Code', company.branchCustomerCode),
                        _item('Branch Name', company.branchName),
                        _item('City', company.branchCity),
                        _item('Status', company.memberOfStatus),
                      ],
                    ),
                    const SizedBox(height: 100),
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
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Selesai',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              Icon(icon, color: AppColors.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
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
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12, color: Colors.black54)),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
}
