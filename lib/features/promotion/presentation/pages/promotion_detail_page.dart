import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/promotion/domain/entities/promotion.dart';
import 'package:ekaplus_ekatunggal/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:flutter/material.dart';

class PromotionDetailResolverPage extends StatelessWidget {
  const PromotionDetailResolverPage({
    super.key,
    required this.id,
    required this.repository,
    this.initial,
  });
  final String id;
  final PromotionRepository repository;
  final Promotion? initial;
  @override
  Widget build(BuildContext context) {
    if (initial != null) return PromotionDetailPage(promotion: initial!);
    return FutureBuilder<Promotion?>(
      future: repository.getPromotionById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }
        return snapshot.data == null
            ? const Scaffold(body: Center(child: Text('Promo tidak tersedia')))
            : PromotionDetailPage(promotion: snapshot.data!);
      },
    );
  }
}

class PromotionDetailPage extends StatelessWidget {
  const PromotionDetailPage({super.key, required this.promotion});
  final Promotion promotion;
  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Detail Promo',
    showBackButton: true,
    backgroundColor: const Color(0xFFF6F7F9),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB11F23), Color(0xFFD52A2F)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.local_offer_outlined,
            color: Colors.white,
            size: 54,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _detailDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (promotion.isDemo)
                const Text(
                  'KONTEN DEMO',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Text(
                promotion.title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                promotion.summary,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
              const Divider(height: 28),
              Text(
                promotion.content,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

const _detailDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
  boxShadow: [
    BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
  ],
);
