import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/promotion/domain/entities/promotion.dart';
import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    required this.onTap,
    this.compact = false,
  });
  final Promotion promotion;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Buka detail promo ${promotion.title}',
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: compact ? 220 : double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Cover(promotion: promotion, height: 124),
                  _Text(promotion, compact: true),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: _Cover(promotion: promotion, height: 118),
                  ),
                  Expanded(child: _Text(promotion, compact: false)),
                ],
              ),
      ),
    ),
  );
}

class _Cover extends StatelessWidget {
  const _Cover({required this.promotion, required this.height});
  final Promotion promotion;
  final double height;
  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB11F23), Color(0xFFD52A2F)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_offer_outlined,
        color: Colors.white,
        size: 34,
      ),
    );
    final image = promotion.coverImage?.trim() ?? '';
    if (image.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class _Text extends StatelessWidget {
  const _Text(this.promotion, {required this.compact});
  final Promotion promotion;
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (promotion.isDemo)
          const Text(
            'DEMO PROMO',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        Text(
          promotion.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 10.5,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          promotion.summary,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
        ),
      ],
    ),
  );
}
