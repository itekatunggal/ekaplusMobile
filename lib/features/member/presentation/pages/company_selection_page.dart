// lib/features/member/presentation/pages/company_selection_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../constant.dart';
import '../../../../core/shared_widgets/custom_header.dart';
import '../enums/member_registration_intent.dart';

/// Page untuk memilih tipe registrasi: GCID (perusahaan baru) atau BCID (cabang)
class CompanySelectionPage extends StatefulWidget {
  const CompanySelectionPage({super.key});

  @override
  State<CompanySelectionPage> createState() => _CompanySelectionPageState();
}

class _CompanySelectionPageState extends State<CompanySelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: const CustomHeaderAppBar(
        title: 'Hubungkan Perusahaan',
        subtitle: 'Pilih jenis pendaftaran',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Text(
                'Pilih Jenis Pendaftaran',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda dapat mendaftarkan perusahaan baru atau menambahkan cabang dari perusahaan yang sudah terdaftar.',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 13,
                  color: AppColors.grayColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Option 1: Tambah Perusahaan Baru (GCID)
              _buildOptionCard(
                context: context,
                icon: Icons.business,
                iconColor: AppColors.primaryColor,
                title: 'Perusahaan Baru',
                subtitle: 'Daftarkan perusahaan baru dengan data lengkap',
                description:
                    'Pilih opsi ini untuk mendaftarkan perusahaan yang benar-benar baru. Anda perlu mengisi semua data perusahaan.',
                onTap: () {
                  context.pushNamed(
                    'memberRegistration',
                    extra: {
                      'intent': MemberRegistrationIntent.newCompany.routeValue,
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Option 2: Tambah Cabang (BCID)
              _buildOptionCard(
                context: context,
                icon: Icons.account_tree,
                iconColor: Colors.green[700]!,
                title: 'Cabang Perusahaan',
                subtitle: 'Tambahkan cabang dari perusahaan yang sudah aktif',
                description:
                    'Pilih opsi ini untuk menambahkan cabang. Data akan diambil dari perusahaan induk, Anda hanya perlu mengubah nama cabang, lokasi, dan alamat.',
                onTap: () {
                  // Navigate to BCID registration page
                  context.pushNamed('addBCID');
                },
              ),

              const Spacer(),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.grayColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: AppColors.grayColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.grayColor,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                color: AppColors.grayColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


