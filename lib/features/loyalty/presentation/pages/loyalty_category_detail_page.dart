import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_calculation_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class LoyaltyCategoryDetailPage extends StatefulWidget {
  const LoyaltyCategoryDetailPage({super.key, required this.item});
  final LoyaltyEarningDetail item;

  @override
  State<LoyaltyCategoryDetailPage> createState() =>
      _LoyaltyCategoryDetailPageState();
}

class _LoyaltyCategoryDetailPageState extends State<LoyaltyCategoryDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0 ||
        position.pixels < position.maxScrollExtent * .90) {
      return;
    }

    final cubit = context.read<LoyaltySourceCubit>();
    final state = cubit.state;
    if (state.status != LoyaltyCalculationStatus.success ||
        state.loadingMore ||
        !state.hasMore) {
      return;
    }
    cubit.loadMore();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Detail Poin',
    showBackButton: true,
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: BlocBuilder<LoyaltySourceCubit, LoyaltySourceState>(
          builder: (context, state) => RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: context.read<LoyaltySourceCubit>().load,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                _CategorySummary(item: widget.item),
                const SizedBox(height: 14),
                _SourceSection(
                  state: state,
                  pointDivider: widget.item.pointDivider,
                  onRetry: context.read<LoyaltySourceCubit>().load,
                ),
                if (state.loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 2.2,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SourceSection extends StatelessWidget {
  const _SourceSection({
    required this.state,
    required this.pointDivider,
    required this.onRetry,
  });

  final LoyaltySourceState state;
  final num pointDivider;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final sourceCount = state.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // SECTION HEADER
        // ============================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              const Text(
                'SUMBER PEMBELIAN',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),

              if (sourceCount > 0) ...[
                const SizedBox(width: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$sourceCount${state.hasMore ? '+' : ''} Entitas',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),

        const SizedBox(height: 9),

        // ============================================================
        // CONTENT
        // ============================================================
        if (state.items.isNotEmpty) ...[
          ...List.generate(state.items.length, (index) {
            final source = state.items[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SourceTile(source: source, pointDivider: pointDivider),
            );
          }),

          if (!state.hasMore && !state.loadingMore)
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 2),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Semua sumber pembelian sudah ditampilkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ] else if (state.status == LoyaltyCalculationStatus.loading)
          const _SourceSkeleton()
        else if (state.status == LoyaltyCalculationStatus.failure)
          _SourceStateMessage(
            title: 'Sumber Pembelian Gagal Dimuat',
            message: 'Periksa koneksi lalu coba kembali.',
            icon: Icons.cloud_off_outlined,
            onRetry: onRetry,
            isError: true,
          )
        else
          const _SourceStateMessage(
            title: 'Belum Ada Rincian Sumber',
            message: 'Detail sumber pembelian belum tersedia.',
            icon: Icons.receipt_long_outlined,
          ),
      ],
    );
  }
}

class _CategorySummary extends StatelessWidget {
  const _CategorySummary({required this.item});

  final LoyaltyEarningDetail item;

  @override
  Widget build(BuildContext context) {
    final hasPoint = item.awardedPoint > 0;

    return Container(
      clipBehavior: Clip.antiAlias,
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
          // ============================================================
          // HEADER CATEGORY
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KATEGORI PEMBELIAN',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9.5,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .45,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFF1F5F9),
          ),

          // ============================================================
          // PURCHASE / POINT RULE
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
            child: Column(
              children: [
                _CategoryInfoRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'Total Pembelian',
                  value: formatMoney(item.purchaseAmount),
                ),

                const SizedBox(height: 11),

                _CategoryInfoRow(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Ketentuan Poin',
                  value: '${formatMoney(item.pointDivider)} = 1 Poin',
                  valueAsBadge: true,
                ),
              ],
            ),
          ),

          // ============================================================
          // POINT AREA
          // ============================================================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBF5),
              border: Border(
                top: BorderSide(color: Color(0xFFF8EDE2), width: .8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'POIN DIPEROLEH',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 9.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .45,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        hasPoint
                            ? 'Perolehan dari kategori ini'
                            : 'Belum memenuhi ketentuan poin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatPointNumber(item.awardedPoint),
                      style: TextStyle(
                        color: hasPoint
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Poin',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 8.5,
                        height: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryInfoRow extends StatelessWidget {
  const _CategoryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueAsBadge = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool valueAsBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFA8B4C5)),
        const SizedBox(width: 7),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: valueAsBadge
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 8.5,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source, required this.pointDivider});

  final LoyaltyPurchaseSource source;
  final num pointDivider;

  @override
  Widget build(BuildContext context) {
    final point = pointDivider > 0
        ? (source.purchaseAmount / pointDivider).floor()
        : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ============================================================
          // ICON
          // ============================================================
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFF475569),
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          // ============================================================
          // CUSTOMER / BC
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  source.customerGroupName ?? source.bcReference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          source.bcReference,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontFamily: AppFonts.secondaryFont,
                            fontSize: 8,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .1,
                          ),
                        ),
                      ),
                    ),
                    if ((source.branchCity ?? '').isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 10,
                                color: Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  source.branchCity!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 8,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ============================================================
          // AMOUNT + POINT
          // ============================================================
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatMoney(source.purchaseAmount),
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 9.5,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: point > 0
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: point > 0
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFE2E8F0),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  point > 0 ? '+$point Poin' : '0 Poin',
                  style: TextStyle(
                    color: point > 0
                        ? const Color(0xFF059669)
                        : const Color(0xFF94A3B8),
                    fontSize: 8,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceSkeleton extends StatelessWidget {
  const _SourceSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Column(
      children: List.generate(
        4,
        (index) => Container(
          height: 68,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: 70,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 76,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SourceStateMessage extends StatelessWidget {
  const _SourceStateMessage({
    required this.title,
    required this.message,
    required this.icon,
    this.onRetry,
    this.isError = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool isError;

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
          decoration: BoxDecoration(
            color: isError ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isError ? AppColors.primaryColor : const Color(0xFF94A3B8),
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            height: 1.4,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
