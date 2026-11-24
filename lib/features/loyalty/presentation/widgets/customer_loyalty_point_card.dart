import 'dart:math' as math;

import 'package:ekaplus_ekatunggal/features/customer/presentation/widgets/customer_menu_section.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/customer_point_summary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class CustomerLoyaltyPointCard extends StatelessWidget {
  const CustomerLoyaltyPointCard({
    super.key,
    required this.onCatalogTap,
    required this.onDetailTap,
    required this.onRetry,
  });

  final VoidCallback? onCatalogTap;
  final VoidCallback? onDetailTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomerSectionTitle(title: 'EkaPoint & Hadiah'),
        const SizedBox(height: 8),
        BlocBuilder<CustomerPointSummaryCubit, CustomerPointSummaryState>(
          builder: (context, state) => Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 126),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                transform: GradientRotation(82 * math.pi / 180),
                colors: [Color(0xFFFDECC5), Color(0xFFFFFDF9)],
                stops: [0.43, 0.76],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: _content(state),
          ),
        ),
      ],
    );
  }

  Widget _content(CustomerPointSummaryState state) {
    if (state.status == CustomerPointSummaryStatus.initial ||
        state.status == CustomerPointSummaryStatus.loading) {
      return const _LoyaltyShimmer();
    }
    if (state.status == CustomerPointSummaryStatus.failure) {
      return _LoyaltyPrompt(
        title: 'Poin belum dapat dimuat',
        message: 'Periksa koneksi lalu coba kembali.',
        label: 'Coba Lagi',
        action: onRetry,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Semantics(
            button: onCatalogTap != null,
            label: 'Buka katalog reward',
            child: InkWell(
              onTap: onCatalogTap,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/icon_medali.png',
                    width: 61,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EKAPOINT', style: _loyaltyTitle),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            NumberFormat.decimalPattern(
                              'id_ID',
                            ).format(state.availablePoint),
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 34,
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Poin Tersedia',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onDetailTap,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rincian Poin',
                  style: TextStyle(
                    color: Color(0xFFD43D45),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFD43D45),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoyaltyPrompt extends StatelessWidget {
  const _LoyaltyPrompt({
    required this.title,
    required this.message,
    required this.label,
    required this.action,
  });

  final String title;
  final String message;
  final String label;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Image.asset(
        'assets/icons/icon_medali.png',
        width: 36,
        fit: BoxFit.contain,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _loyaltyTitle),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 9.5),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: FilledButton(
                onPressed: action,
                style: FilledButton.styleFrom(
                  backgroundColor: _loyaltyRed,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _LoyaltyShimmer extends StatelessWidget {
  const _LoyaltyShimmer();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFEADDBD),
    highlightColor: const Color(0xFFFFF9EA),
    child: SizedBox(
      height: 90,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoyaltyShimmerBar(width: 78, height: 12),
                SizedBox(height: 7),
                _LoyaltyShimmerBar(width: 72, height: 30),
                SizedBox(height: 6),
                _LoyaltyShimmerBar(width: 62, height: 8),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _LoyaltyShimmerBar(width: 76, height: 12),
        ],
      ),
    ),
  );
}

class _LoyaltyShimmerBar extends StatelessWidget {
  const _LoyaltyShimmerBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

const _loyaltyTitle = TextStyle(
  color: _loyaltyRed,
  fontSize: 15,
  fontWeight: FontWeight.w700,
);
const _loyaltyRed = Color(0xFFB21E2B);
