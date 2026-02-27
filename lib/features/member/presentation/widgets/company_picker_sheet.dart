import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:flutter/material.dart';

class CompanyPickerSheet extends StatelessWidget {
  final List<ActiveMemberCompany> companies;
  final int? activeBcid;
  final ValueChanged<ActiveMemberCompany> onSelectCompany;
  final VoidCallback onAddCompany;

  const CompanyPickerSheet({
    super.key,
    required this.companies,
    required this.activeBcid,
    required this.onSelectCompany,
    required this.onAddCompany,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Text(
              'Pilih Perusahaan',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 32 / 2, // keep it visually close to mockup
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: companies.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Belum ada perusahaan aktif.',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      )
                    : Column(
                        children: companies.map((company) {
                          final isActive =
                              company.branchCustomerId == activeBcid;
                          return InkWell(
                            onTap: () => onSelectCompany(company),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          company.displayName,
                                          style: TextStyle(
                                            fontFamily: AppFonts.primaryFont,
                                            fontSize: 27 / 2,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Builder(
                                          builder: (_) {
                                            final branchName =
                                                (company.branchName ?? '')
                                                    .trim();
                                            // final city =
                                            //     (company.branchCity ?? '')
                                            //         .trim();
                                            final subtitle = branchName;
                                            // '$branchName - $city';

                                            return Text(
                                              subtitle,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppFonts.primaryFont,
                                                fontSize: 22 / 2,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF9CA3AF),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 180),
                                    opacity: isActive ? 1 : 0.35,
                                    child: Icon(
                                      isActive
                                          ? Icons.check_circle_outline
                                          : Icons.radio_button_unchecked,
                                      size: 20,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 2),
            TextButton(
              onPressed: onAddCompany,
              child: Text(
                'Tambahkan Perusahaan Lainnya',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB91C1C),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
