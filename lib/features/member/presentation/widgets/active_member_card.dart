// lib/features/member/presentation/widgets/active_member_card.dart

import 'package:flutter/material.dart';
import '../../../../constant.dart';
import '../../domain/entities/active_member_company.dart';
import '../utils/member_status_helper.dart';

class ActiveMemberCard extends StatelessWidget {
  final ActiveMemberCompany company;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onInfoTap;
  final bool isActiveSelected;

  const ActiveMemberCard({
    super.key,
    required this.company,
    required this.onTap,
    this.onLongPress,
    this.onInfoTap,
    this.isActiveSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = company.displayName;
    final branchName = company.branchName ?? '-';
    final picBranchName = (company.branchOwnerName ?? '').trim().isEmpty
        ? '-'
        : company.branchOwnerName!.trim();
    final picBranchPhone = (company.branchOwnerPhone ?? '').trim().isEmpty
        ? '-'
        : company.branchOwnerPhone!.trim();
    final normalizedStatus = MemberStatusHelper.normalize(
      company.customerRegisterStatus,
    );
    final borderRadius = BorderRadius.circular(12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: (isActiveSelected ? Colors.green : Colors.black).withOpacity(
              isActiveSelected ? 0.12 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.whiteColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: isActiveSelected ? Colors.green[300]! : Colors.grey[200]!,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: AppColors.primaryColor.withOpacity(0.18),
          highlightColor: AppColors.primaryColor.withOpacity(0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with active badge
              Ink(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActiveSelected ? Colors.green[50] : Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Ink(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 24,
                        color: isActiveSelected
                            ? Colors.green[700]
                            : Colors.grey[700],
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
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: 1,
                            child: Row(
                              children: [
                                if (isActiveSelected) ...[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green[600],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  isActiveSelected ? 'Aktif' : normalizedStatus,
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(normalizedStatus),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onInfoTap != null)
                      IconButton(
                        onPressed: onInfoTap,
                        icon: const Icon(Icons.info_outline),
                        tooltip: 'Detail',
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
                    // _buildInfoRow(
                    //   Icons.workspace_premium_outlined,
                    //   'NB',
                    //   nationalBrand,
                    // ),

                    // const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.person_outline,
                      'PIC Branch name',
                      picBranchName,
                    ),

                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'No. HP PIC Branch',
                      picBranchPhone,
                    ),

                    const SizedBox(height: 8),

                    // Branch
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Cabang yang dipilih',
                      branchName,
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green[700]!;
      case 'rejected':
        return Colors.red[700]!;
      case 'draft':
        return Colors.grey[700]!;
      case 'request':
      case 'in review':
      default:
        return Colors.orange[700]!;
    }
  }
}
