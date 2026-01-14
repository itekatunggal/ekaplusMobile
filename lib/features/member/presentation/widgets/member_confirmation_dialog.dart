// lib/features/member/presentation/widgets/member_confirmation_dialog.dart

import 'package:flutter/material.dart';
import '../../../../constant.dart';

class MemberConfirmationDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Dialog(
      // Tambahkan insetPadding untuk memperlebar dialog
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // AKTIFKAN ROUNDED CORNER
      ),
      // Tambahkan clipBehavior agar rounded benar-benar terlihat
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        color: AppColors.whiteColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // Ubah dari 8 ke 16
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentitySection(),
                    const SizedBox(height: 12),
                    _buildCompanySection(),
                    const SizedBox(height: 12),
                    _buildAddressSection(),
                    const SizedBox(height: 12),
                    _buildSupportingSection(),
                    // Dokumen tidak perlu ditampilkan karena tidak tersimpan
                    // const SizedBox(height: 12),
                    // _buildDocumentsSection(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16), // Ubah dari 8 ke 16
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        // HAPUS borderRadius di sini karena sudah ada di Dialog
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Konfirmasi Data Registrasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent, // Hilangkan garis atas bawah
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: const Text(
            'Data Identitas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  _buildDataRow('Nama', formData['nama']),
                  _buildDataRow('Email', formData['email']),
                  _buildDataRow('Telepon', formData['phone']),
                  _buildDataRow('Tempat Lahir', formData['birthPlace']),
                  _buildDataRow('Tanggal Lahir', formData['dateOfBirth']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent, // Hilangkan garis atas bawah
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: const Text(
            'Informasi Perusahaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  _buildDataRow('Jenis Perusahaan', formData['company_type']),
                  _buildDataRow('Nama Perusahaan', formData['company_name']),
                  _buildDataRow('NIK', formData['nik']),
                  _buildDataRow('NPWP', formData['npwp']),
                  _buildDataRow('Cabang', formData['branch_name']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent, // Hilangkan garis atas bawah
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: const Text(
            'Alamat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  _buildDataRow('Alamat Lengkap', formData['address']),
                  _buildDataRow('Provinsi', formData['province_name']),
                  _buildDataRow('Kota/Kabupaten', formData['regency_name']),
                  _buildDataRow('Kecamatan', formData['district_name']),
                  _buildDataRow('Kelurahan/Desa', formData['village_name']),
                  _buildDataRow('RT', formData['rt']),
                  _buildDataRow('RW', formData['rw']),
                  _buildDataRow('Kode Pos', formData['postal_code']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent, // Hilangkan garis atas bawah
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: const Text(
            'Data Pendukung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  _buildDataRow('Contact Person', formData['contact_person']),
                  _buildDataRow('Email Perusahaan', formData['email_company']),
                  if (formData['fax'] != null &&
                      formData['fax'].toString().isNotEmpty)
                    _buildDataRow('Fax', formData['fax']),
                  if (formData['factory_address'] != null &&
                      formData['factory_address'].toString().isNotEmpty)
                    _buildDataRow('Alamat Pabrik', formData['factory_address']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildDocumentsSection() {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Theme(
  //       data: ThemeData(
  //         dividerColor: Colors.transparent, // Hilangkan garis atas bawah
  //       ),
  //       child: ExpansionTile(
  //         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         title: const Text(
  //           'Dokumen',
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: AppColors.primaryColor,
  //           ),
  //         ),
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
  //             child: Column(
  //               children: [
  //                 _buildFileRow('KTP', formData['ktp_file']),
  //                 _buildFileRow('NPWP', formData['npwp_file']),
  //                 if (formData['company_doc_file'] != null)
  //                   _buildFileRow('Dokumen Perusahaan', formData['company_doc_file']),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150, // Kurangi dari 180 ke 150 agar lebih proporsional
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13, // Ubah dari 12 ke 13
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(':', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(
                fontSize: 13, // Ubah dari 12 ke 13
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildFileRow(String label, dynamic filePath) {
  //   String fileName = '-';
  //   if (filePath != null && filePath.toString().isNotEmpty) {
  //     final pathStr = filePath.toString();
  //     fileName = pathStr.split('/').last.split('\\').last;
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 12),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 150, // Kurangi dari 180 ke 150
  //           child: Text(
  //             label,
  //             style: const TextStyle(
  //               fontSize: 13, // Ubah dari 14 ke 13
  //               color: Colors.grey,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 8),
  //         const Text(':', style: TextStyle(fontSize: 13, color: Colors.grey)),
  //         const SizedBox(width: 8),
  //         Expanded(
  //           child: Row(
  //             children: [
  //               const Icon(
  //                 Icons.attach_file,
  //                 size: 16,
  //                 color: AppColors.grayColor,
  //               ),
  //               const SizedBox(width: 4),
  //               Expanded(
  //                 child: Text(
  //                   fileName,
  //                   style: const TextStyle(
  //                     fontSize: 13, // Ubah dari 14 ke 13
  //                     fontWeight: FontWeight.w500,
  //                     color: AppColors.secondaryColor,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        // HAPUS borderRadius di sini juga
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Perbaiki Data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Yakin, Kirim Formulir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
