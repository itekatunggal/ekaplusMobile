// lib/features/member/presentation/pages/company_selection_page.dart

import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_member_registrations_by_user_id.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../constant.dart';
import '../../../../core/shared_widgets/custom_header.dart';
import '../enums/member_registration_intent.dart';
import '../utils/member_status_helper.dart';

/// Page untuk memilih tipe registrasi: GCID (perusahaan baru) atau BCID (cabang)
class CompanySelectionPage extends StatefulWidget {
  const CompanySelectionPage({super.key});

  @override
  State<CompanySelectionPage> createState() => _CompanySelectionPageState();
}

class _CompanySelectionPageState extends State<CompanySelectionPage> {
  final GetMemberRegistrationsByUserId _getMemberRegistrationsByUserId =
      myinjection<GetMemberRegistrationsByUserId>();

  bool _isLoadingRegistrations = true;
  bool _hasPendingNewCompanyRequest = false;

  @override
  void initState() {
    super.initState();
    _loadRegistrationState();
  }

  Future<void> _loadRegistrationState() async {
    final result = await _getMemberRegistrationsByUserId.execute();
    if (!mounted) return;

    result.fold(
      (_) {
        setState(() {
          _hasPendingNewCompanyRequest = false;
          _isLoadingRegistrations = false;
        });
      },
      (registrations) {
        setState(() {
          _hasPendingNewCompanyRequest = registrations.any(
            (registration) =>
                MemberStatusHelper.isPendingSubmission(registration.status),
          );
          _isLoadingRegistrations = false;
        });
      },
    );
  }

  void _handleNewCompanyTap() {
    if (_hasPendingNewCompanyRequest) {
      AppSnackbar.show(
        context,
        message:
            'Pengajuan perusahaan baru tidak bisa dibuat karena masih ada status Request/In Review.',
        type: AppSnackbarType.warning,
      );
      return;
    }

    context.pushNamed(
      'memberRegistration',
      extra: {'intent': MemberRegistrationIntent.newCompany.routeValue},
    );
  }

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
              _buildOptionCard(
                context: context,
                icon: Icons.business,
                iconColor: AppColors.primaryColor,
                title: 'Perusahaan Baru',
                subtitle: _hasPendingNewCompanyRequest
                    ? 'Tidak tersedia saat masih ada pengajuan Request/In Review'
                    : 'Daftarkan perusahaan baru dengan data lengkap',
                description:
                    'Pilih opsi ini untuk mendaftarkan perusahaan yang benar-benar baru. Anda perlu mengisi semua data perusahaan.',
                onTap: _isLoadingRegistrations ? null : _handleNewCompanyTap,
                isDisabled:
                    _isLoadingRegistrations || _hasPendingNewCompanyRequest,
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context: context,
                icon: Icons.account_tree,
                iconColor: Colors.green[700]!,
                title: 'Cabang Perusahaan',
                subtitle: 'Tambahkan cabang dari perusahaan yang sudah aktif',
                description:
                    'Pilih opsi ini untuk menambahkan cabang. Data akan diambil dari perusahaan induk, Anda hanya perlu mengubah nama cabang, lokasi, dan alamat.',
                onTap: () {
                  context.pushNamed('addBCID');
                },
              ),
              const Spacer(),
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
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[100] : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDisabled ? 0.02 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDisabled ? Colors.grey : iconColor).withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled ? Colors.grey[500] : iconColor,
                    size: 28,
                  ),
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
                          color: isDisabled
                              ? Colors.grey[600]
                              : AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: isDisabled
                              ? Colors.grey[500]
                              : AppColors.grayColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDisabled ? Colors.grey[400] : AppColors.grayColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                color: isDisabled ? Colors.grey[500] : AppColors.grayColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
