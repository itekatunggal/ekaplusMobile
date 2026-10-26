import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/widgets/category_icon_image.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_calculation_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/pages/loyalty_category_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/pages/loyalty_redemption_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class LoyaltyCalculationDetailPage extends StatelessWidget {
  const LoyaltyCalculationDetailPage({
    super.key,
    this.groupParentCode,
    this.groupParentName,
  });

  final String? groupParentCode;
  final String? groupParentName;

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Rincian Poin',
    showBackButton: true,
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: BlocBuilder<LoyaltyCalculationCubit, LoyaltyCalculationState>(
          builder: (context, state) => RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: context.read<LoyaltyCalculationCubit>().load,
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                if (state.status == LoyaltyCalculationStatus.initial ||
                    state.status == LoyaltyCalculationStatus.loading)
                  const _CalculationSkeleton()
                else if (state.status == LoyaltyCalculationStatus.failure)
                  _ErrorCard(
                    message: 'Rincian poin belum dapat dimuat.',
                    onRetry: context
                        .read<LoyaltyCalculationCubit>()
                        .loadCalculation,
                  )
                else ...[
                  _LedgerSummary(
                    ledger: state.ledger,
                    groupParentCode: groupParentCode,
                    groupParentName: groupParentName,
                  ),
                  const SizedBox(height: 16),
                  _SectionHeading(title: 'Perolehan Berdasarkan Kategori'),
                  const SizedBox(height: 8),
                  if (state.details.isEmpty)
                    const _EmptyCard(
                      icon: Icons.add_chart_rounded,
                      title: 'Belum Ada Perolehan Poin',
                      message:
                          'Rincian pembelian yang masuk dalam perhitungan poin akan tampil di sini.',
                    )
                  else
                    ...state.details.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CategoryTicket(
                          item: item,
                          categoryIcon: _findCategoryIcon(
                            state.categoryIcons,
                            item.category,
                          ),
                          onTap: state.ledger == null
                              ? null
                              : () =>
                                    _openCategory(context, state.ledger!, item),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _SectionHeading(
                    title: 'Riwayat Penukaran',
                    trailing: 'Aktivitas Terbaru',
                  ),
                  const SizedBox(height: 8),
                  _HistoryPreview(state: state),
                  if (state.history.isNotEmpty &&
                      context.read<LoyaltyCalculationCubit>().bcid != null)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => context.pushNamed(
                          'loyalty-history',
                          extra: {
                            'bcid': context
                                .read<LoyaltyCalculationCubit>()
                                .bcid,
                          },
                        ),
                        label: const Text('Lihat Semua Riwayat'),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.chevron_right_rounded, size: 17),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          textStyle: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  String? _findCategoryIcon(Map<String, String> categoryIcons, String name) {
    final target = _normalizeCategoryName(name);
    if (target.isEmpty) return null;

    for (final entry in categoryIcons.entries) {
      if (_normalizeCategoryName(entry.key) == target) return entry.value;
    }

    for (final entry in categoryIcons.entries) {
      final candidate = _normalizeCategoryName(entry.key);
      if (candidate.isNotEmpty &&
          (candidate.contains(target) || target.contains(candidate))) {
        return entry.value;
      }
    }

    // Toleransi typo kecil yang belum tercakup alias, tanpa mencocokkan nama
    // pendek seperti HDP secara terlalu agresif.
    String? closestIcon;
    var closestDistance = target.length;
    for (final entry in categoryIcons.entries) {
      final candidate = _normalizeCategoryName(entry.key);
      if (candidate.length < 4) continue;

      final distance = _editDistance(target, candidate);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIcon = entry.value;
      }
    }

    final allowedDistance = target.length <= 6
        ? 1
        : target.length <= 12
        ? 2
        : 3;
    return closestDistance <= allowedDistance ? closestIcon : null;
  }

  String _normalizeCategoryName(String value) {
    var normalized = value
        .toLowerCase()
        .replaceFirst(RegExp(r'^penjualan\s+'), '')
        .replaceAll(RegExp(r'\bplastic\b'), 'plastik')
        .replaceAll(
          RegExp(r'\b(accessories|accesorries|accessory|asesoris)\b'),
          'aksesoris',
        )
        .replaceAll(RegExp(r'\bpercoil\b'), 'percale')
        .replaceAll(RegExp(r'\b(chemical|chemicals|bahan kimia)\b'), 'kimia');

    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return normalized;
  }

  int _editDistance(String left, String right) {
    if (left == right) return 0;
    if (left.isEmpty) return right.length;
    if (right.isEmpty) return left.length;

    var previous = List<int>.generate(right.length + 1, (index) => index);
    for (var leftIndex = 1; leftIndex <= left.length; leftIndex++) {
      final current = List<int>.filled(right.length + 1, 0);
      current[0] = leftIndex;

      for (var rightIndex = 1; rightIndex <= right.length; rightIndex++) {
        final substitutionCost =
            left.codeUnitAt(leftIndex - 1) == right.codeUnitAt(rightIndex - 1)
            ? 0
            : 1;
        current[rightIndex] = [
          current[rightIndex - 1] + 1,
          previous[rightIndex] + 1,
          previous[rightIndex - 1] + substitutionCost,
        ].reduce((first, second) => first < second ? first : second);
      }

      previous = current;
    }

    return previous.last;
  }

  void _openCategory(
    BuildContext context,
    LoyaltyLedger ledger,
    LoyaltyEarningDetail item,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LoyaltySourceCubit(
            LoyaltyService(),
            calculationId: ledger.calculationId,
            account: item.account,
          )..load(),
          child: LoyaltyCategoryDetailPage(item: item),
        ),
      ),
    );
  }
}

class _LedgerSummary extends StatelessWidget {
  const _LedgerSummary({
    required this.ledger,
    this.groupParentCode,
    this.groupParentName,
  });

  final LoyaltyLedger? ledger;
  final String? groupParentCode;
  final String? groupParentName;

  @override
  Widget build(BuildContext context) {
    final name = (groupParentName ?? 'Group Parent').trim().toUpperCase();
    // final code = (groupParentCode ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // IDENTITAS GRUP
          // =========================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primaryColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 11.5,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Group Parent',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                            height: 1.2,
                          ),
                        ),
                        // if (code.isNotEmpty) ...[
                        //   const SizedBox(width: 6),
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 6,
                        //       vertical: 2,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: const Color(0xFFF1F5F9),
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //     child: Text(
                        //       code,
                        //       style: const TextStyle(
                        //         color: Color(0xFF475569),
                        //         fontSize: 8,
                        //         height: 1.1,
                        //         fontWeight: FontWeight.w600,
                        //         letterSpacing: .2,
                        //       ),
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // =========================
          // SALDO POIN
          // =========================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Saldo poin keseluruhan',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (ledger?.validTo != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 10,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Berlaku sampai ${formatDate(ledger!.validTo)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 8.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatPointNumber(ledger?.earnedPoint ?? 0),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Poin',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10.5,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .45,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    ),
  );
}

class _CategoryTicket extends StatelessWidget {
  const _CategoryTicket({
    required this.item,
    required this.categoryIcon,
    required this.onTap,
  });

  final LoyaltyEarningDetail item;
  final String? categoryIcon;
  final VoidCallback? onTap;

  static const double _pointAreaWidth = 72;
  static const double _notchRadius = 5.0;
  static const double _cardRadius = 16;

  @override
  Widget build(BuildContext context) {
    final hasPoint = item.awardedPoint > 0;

    final shortage = item.pointDivider > item.purchaseAmount
        ? item.pointDivider - item.purchaseAmount
        : 0;

    return PhysicalShape(
      clipper: const _TicketClipper(
        pointAreaWidth: _pointAreaWidth,
        notchRadius: _notchRadius,
        radius: _cardRadius,
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x120F172A),
      child: CustomPaint(
        foregroundPainter: const _TicketBorderPainter(
          pointAreaWidth: _pointAreaWidth,
          notchRadius: _notchRadius,
          radius: _cardRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    // PENTING:
                    // jangan gunakan CrossAxisAlignment.stretch
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // =========================
                      // LEFT AREA
                      // =========================
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 11, right: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 42,
                                height: 42,
                                // decoration: BoxDecoration(
                                //   color: hasPoint
                                //       ? const Color(0xFFFFE4E6)
                                //       : const Color(0xFFF1F5F9),
                                //   shape: BoxShape.circle,
                                // ),
                                child: Center(
                                  child: CategoryIconImage(
                                    icon: categoryIcon,
                                    size: 40,
                                    fallbackIcon: _categoryIcon(item.category),
                                    fallbackColor: hasPoint
                                        ? AppColors.primaryColor
                                        : const Color(0xFF64748B),
                                    fallbackSize: 18,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 11,
                                        height: 1.15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    // Tetap SATU BARIS.
                                    Text(
                                      'Total Belanja ${formatMoney(item.purchaseAmount)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 8.5,
                                        height: 1.2,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),

                                    if (!hasPoint && shortage > 0) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        'Kurang ${formatMoney(shortage)} lagi',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 8,
                                          height: 1.2,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // =========================
                      // RIGHT POINT AREA
                      // =========================
                      SizedBox(
                        width: _pointAreaWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              hasPoint
                                  ? '+${formatPointNumber(item.awardedPoint)}'
                                  : '0',
                              style: TextStyle(
                                color: hasPoint
                                    ? const Color(0xFF047857)
                                    : const Color(0xFF94A3B8),
                                fontSize: 13.5,
                                height: 1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'POIN',
                              style: TextStyle(
                                color: hasPoint
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFFA8B2C1),
                                fontSize: 8,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // PERFORATION LINE
                // =========================
                const Positioned(
                  right: _pointAreaWidth - .5,
                  top: 8,
                  bottom: 8,
                  child: SizedBox(
                    width: 1,
                    child: CustomPaint(painter: _DashedDividerPainter()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final value = category.toLowerCase();

    if (value.contains('kimia')) {
      return Icons.science_outlined;
    }

    if (value.contains('plastic') || value.contains('plastik')) {
      return Icons.layers_outlined;
    }

    if (value.contains('kawat')) {
      return Icons.linear_scale_rounded;
    }

    if (value.contains('kain')) {
      return Icons.texture_rounded;
    }

    if (value.contains('accessories')) {
      return Icons.handyman_outlined;
    }

    if (value.contains('percoil')) {
      return Icons.motion_photos_on_outlined;
    }

    if (value.contains('hdp')) {
      return Icons.texture_rounded;
    }

    return Icons.category_outlined;
  }
}

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({
    required this.pointAreaWidth,
    required this.notchRadius,
    required this.radius,
  });

  final double pointAreaWidth;
  final double notchRadius;
  final double radius;

  @override
  Path getClip(Size size) {
    final dividerX = size.width - pointAreaWidth;
    return _buildTicketShape(
      size: size,
      dividerX: dividerX,
      notchRadius: notchRadius,
      radius: radius,
    );
  }

  @override
  bool shouldReclip(covariant _TicketClipper oldClipper) {
    return oldClipper.pointAreaWidth != pointAreaWidth ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.radius != radius;
  }
}

class _TicketBorderPainter extends CustomPainter {
  const _TicketBorderPainter({
    required this.pointAreaWidth,
    required this.notchRadius,
    required this.radius,
  });

  final double pointAreaWidth;
  final double notchRadius;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final dividerX = size.width - pointAreaWidth;

    final path = _buildTicketShape(
      size: size,
      dividerX: dividerX,
      notchRadius: notchRadius,
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = const Color(0xFFE5E7EB);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TicketBorderPainter oldDelegate) {
    return oldDelegate.pointAreaWidth != pointAreaWidth ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.radius != radius;
  }
}

Path _buildTicketShape({
  required Size size,
  required double dividerX,
  required double notchRadius,
  required double radius,
}) {
  final outer = Path()
    ..addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    );

  final holes = Path()
    ..addOval(Rect.fromCircle(center: Offset(dividerX, 0), radius: notchRadius))
    ..addOval(
      Rect.fromCircle(
        center: Offset(dividerX, size.height),
        radius: notchRadius,
      ),
    );

  return Path.combine(PathOperation.difference, outer, holes);
}

/// Border tipis mengikuti bentuk card + notch.
// class _TicketBorderPainter extends CustomPainter {
//   const _TicketBorderPainter({
//     required this.pointAreaWidth,
//     required this.notchRadius,
//     required this.radius,
//   });

//   final double pointAreaWidth;
//   final double notchRadius;
//   final double radius;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final dividerX = size.width - pointAreaWidth;

//     final path = _buildTicketPath(
//       size: size,
//       dividerX: dividerX,
//       notchRadius: notchRadius,
//       radius: radius,
//     );

//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = .8
//       ..color = const Color(0xFFE5E7EB);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant _TicketBorderPainter oldDelegate) {
//     return oldDelegate.pointAreaWidth != pointAreaWidth ||
//         oldDelegate.notchRadius != notchRadius ||
//         oldDelegate.radius != radius;
//   }
// }

// Path _buildTicketPath({
//   required Size size,
//   required double dividerX,
//   required double notchRadius,
//   required double radius,
// }) {
//   final path = Path()..fillType = PathFillType.evenOdd;

//   path.addRRect(
//     RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
//   );

//   // Notch atas.
//   path.addOval(
//     Rect.fromCircle(center: Offset(dividerX, 0), radius: notchRadius),
//   );

//   // Notch bawah.
//   path.addOval(
//     Rect.fromCircle(center: Offset(dividerX, size.height), radius: notchRadius),
//   );

//   return path;
// }

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD7DEE7).withValues(alpha: .58)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const dashHeight = 2.2;
    const dashGap = 3.8;

    double y = 0;

    while (y < size.height) {
      final endY = (y + dashHeight).clamp(0.0, size.height);

      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, endY),
        paint,
      );

      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HistoryPreview extends StatelessWidget {
  const _HistoryPreview({required this.state});
  final LoyaltyCalculationState state;

  @override
  Widget build(BuildContext context) {
    if (state.history.isNotEmpty) {
      return Column(
        children: state.history.take(2).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _HistoryCard(
              item: item,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LoyaltyRedemptionDetailPage(item: item),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
    if (state.historyStatus == LoyaltyCalculationStatus.initial ||
        state.historyStatus == LoyaltyCalculationStatus.loading) {
      return const _HistorySkeleton();
    }
    if (state.historyStatus == LoyaltyCalculationStatus.failure) {
      return _ErrorCard(
        message: 'Riwayat penukaran belum dapat dimuat.',
        onRetry: context.read<LoyaltyCalculationCubit>().loadHistory,
      );
    }
    return const _EmptyCard(
      icon: Icons.history_rounded,
      title: 'Belum Ada Riwayat',
      message: 'Aktivitas penukaran poin akan tampil di sini.',
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onTap});
  final LoyaltyRedemption item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      LoyaltyRedemptionStatus.approved => const Color(0xFF059669),
      LoyaltyRedemptionStatus.rejected => AppColors.primaryColor,
      _ => const Color(0xFFD97706),
    };
    final statusBackground = switch (item.status) {
      LoyaltyRedemptionStatus.approved => const Color(0xFFECFDF5),
      LoyaltyRedemptionStatus.rejected => const Color(0xFFFFF1F2),
      _ => const Color(0xFFFFFBEB),
    };
    final statusBorder = switch (item.status) {
      LoyaltyRedemptionStatus.approved => const Color(0xFFA7F3D0),
      LoyaltyRedemptionStatus.rejected => const Color(0xFFFECACA),
      _ => const Color(0xFFFDE68A),
    };
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
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
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.redeem_rounded,
                  color: AppColors.primaryColor,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.rewardName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusBorder),
                      ),
                      child: Text(
                        redemptionStatusLabel(item.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${formatPoint(item.pointUsed)}',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatDate(item.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE4E6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Data Belum Dapat Dimuat',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 17),
          label: const Text('Coba Lagi'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor),
            minimumSize: const Size(132, 42),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF94A3B8), size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _CalculationSkeleton extends StatelessWidget {
  const _CalculationSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE2E8F0),
    highlightColor: const Color(0xFFF8FAFC),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonCard(height: 124),
        const SizedBox(height: 16),
        const _SkeletonLine(width: 190, height: 10),
        const SizedBox(height: 8),
        for (var index = 0; index < 3; index++) ...[
          const _SkeletonCard(height: 66),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        const _SkeletonLine(width: 128, height: 10),
        const SizedBox(height: 8),
        const _SkeletonCard(height: 64),
        const SizedBox(height: 8),
        const _SkeletonCard(height: 64),
      ],
    ),
  );
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE2E8F0),
    highlightColor: const Color(0xFFF8FAFC),
    child: const Column(
      children: [
        _SkeletonCard(height: 64),
        SizedBox(height: 8),
        _SkeletonCard(height: 64),
      ],
    ),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
