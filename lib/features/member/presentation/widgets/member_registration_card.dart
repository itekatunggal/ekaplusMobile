// lib/features/member/presentation/widgets/member_registration_card.dart

import 'package:flutter/material.dart';
import '../../../../constant.dart';
import '../../../member/domain/entities/member_registration.dart';
import 'package:intl/intl.dart';
import '../utils/member_status_helper.dart';

class MemberRegistrationCard extends StatelessWidget {
  final MemberRegistration registration;
  final VoidCallback onTap;

  const MemberRegistrationCard({
    super.key,
    required this.registration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = MemberStatusHelper.normalize(registration.status);
    final isDraft = MemberStatusHelper.isDraft(registration.status);
    final companyName = registration.businessName;
    final branchName =
        registration.branch.city != null &&
            registration.branch.city!.trim().isNotEmpty
        ? '${registration.branch.branchName} - ${registration.branch.city}'
        : registration.branch.branchName;
    final dateLabel = isDraft ? 'Diupdate' : 'Diajukan';
    final displayDate = isDraft
        ? registration.updatedAt
        : registration.createdAt;
    final formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(displayDate.toLocal());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$companyName - ${registration.branch.city}',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(normalizedStatus),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.grayColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          branchName,
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 12,
                            color: AppColors.grayColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.grayColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$dateLabel: $formattedDate',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 11,
                          color: AppColors.grayColor,
                        ),
                      ),
                    ],
                  ),
                  if (MemberStatusHelper.isRejected(registration.status) &&
                      ((registration.rejectReason ?? '').trim().isNotEmpty ||
                          (registration.rejectNotes ?? '')
                              .trim()
                              .isNotEmpty)) ...[
                    const SizedBox(height: 8),
                    if ((registration.rejectReason ?? '').trim().isNotEmpty)
                      _buildRejectItem(
                        'Alasan Reject',
                        registration.rejectReason!,
                      ),
                    if ((registration.rejectNotes ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildRejectItem(
                        'Catatan Reject',
                        registration.rejectNotes!,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String normalizedStatus) {
    Color backgroundColor;
    Color textColor;

    switch (normalizedStatus.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        break;
      case 'draft':
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        break;
      case 'request':
      case 'in review':
      default:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        normalizedStatus,
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRejectItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.report_problem_outlined, size: 16, color: Colors.red[700]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 11.5,
              color: Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // String _formatDate(String? dateStr) {
  //   if (dateStr == null || dateStr.isEmpty) return '-';
  //   try {
  //     final date = DateTime.parse(dateStr);
  //     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  //   } catch (e) {
  //     return dateStr;
  //   }
  // }
}
