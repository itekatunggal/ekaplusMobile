// lib/features/member/presentation/widgets/active_member_card.dart

import 'package:flutter/material.dart';
import '../../../../constant.dart';
import '../../domain/entities/active_member_company.dart';

class ActiveMemberCard extends StatelessWidget {
  final ActiveMemberCompany company;
  final VoidCallback onTap;

  const ActiveMemberCard({
    super.key,
    required this.company,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = company.displayName;
    final branchName = company.branchName ?? '-';
    final nationalBrand = company.nbName ?? '-';
    final groupParent = company.gpCode ?? '-';
    final memberId = company.branchCustomerCode ?? 'BCID #${company.refId}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with active badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      size: 24,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green[600],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Aktif',
                              style: TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Type
                  _buildInfoRow(Icons.workspace_premium_outlined, 'NB', nationalBrand),

                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.hub_outlined, 'GP', groupParent),

                  const SizedBox(height: 8),

                  // Branch
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Cabang',
                    branchName,
                  ),

                  const SizedBox(height: 8),

                  // Member ID
                  _buildInfoRow(Icons.badge_outlined, 'Member ID', memberId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grayColor),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 12,
            color: AppColors.grayColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
