import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';

class LoyaltyRedemptionDetailPage extends StatelessWidget {
  const LoyaltyRedemptionDetailPage({super.key, required this.item});
  final LoyaltyRedemption item;
  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Detail Penukaran',
    body: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0F172A),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.card_giftcard_rounded,
                size: 38,
                color: Color(0xFFD97706),
              ),
              const SizedBox(height: 8),
              Text(
                item.rewardName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                redemptionStatusLabel(item.status),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              _row('No. Transaksi', item.name),
              _row('Poin Digunakan', formatPoint(item.pointUsed)),
              _row('Tanggal Pengajuan', formatDate(item.createdAt)),
              _row(
                'Tanggal Selesai',
                formatDate(item.completedAt),
                divider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );

  Widget _row(String label, String value, {bool divider = true}) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      if (divider) const Divider(height: 1, color: Color(0xFFF1F5F9)),
    ],
  );
}
