import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_point_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/pages/loyalty_redemption_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyHistoryPage extends StatefulWidget {
  const LoyaltyHistoryPage({super.key});

  static void openDetail(BuildContext context, LoyaltyRedemption item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoyaltyRedemptionDetailPage(item: item),
      ),
    );
  }

  @override
  State<LoyaltyHistoryPage> createState() => _LoyaltyHistoryPageState();
}

class _LoyaltyHistoryPageState extends State<LoyaltyHistoryPage> {
  LoyaltyRedemptionStatus? _filter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 240) {
      context.read<LoyaltyPointCubit>().loadMoreHistory();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Aktivitas Poin',
    body: BlocBuilder<LoyaltyPointCubit, LoyaltyPointState>(
      builder: (context, state) {
        final rows = _filter == null
            ? state.history
            : state.history.where((item) => item.status == _filter).toList();
        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: context.read<LoyaltyPointCubit>().loadHistory,
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('Semua', null),
                    const SizedBox(width: 6),
                    _chip('Dalam Proses', LoyaltyRedemptionStatus.pending),
                    const SizedBox(width: 6),
                    _chip('Berhasil', LoyaltyRedemptionStatus.approved),
                    const SizedBox(width: 6),
                    _chip('Ditolak', LoyaltyRedemptionStatus.rejected),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              LoyaltySectionCard(
                title: 'Riwayat Penukaran',
                child: state.historyStatus == LoyaltySectionStatus.loading
                    ? const LoyaltyLoading(height: 150)
                    : state.historyStatus == LoyaltySectionStatus.failure
                    ? LoyaltySectionMessage(
                        message: 'Riwayat belum dapat dimuat.',
                        onRetry: context.read<LoyaltyPointCubit>().loadHistory,
                      )
                    : rows.isEmpty
                    ? const LoyaltySectionMessage(
                        message: 'Tidak ada aktivitas untuk filter ini.',
                        icon: Icons.history_rounded,
                      )
                    : LoyaltyDividedList(
                        children: rows
                            .map(
                              (item) => LoyaltyHistoryTile(
                                item: item,
                                onTap: () => LoyaltyHistoryPage.openDetail(
                                  context,
                                  item,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
              if (state.historyLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else if (!state.historyHasMore && state.history.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Semua aktivitas sudah ditampilkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    ),
  );

  Widget _chip(String label, LoyaltyRedemptionStatus? status) {
    final selected = _filter == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = status),
      selectedColor: const Color(0xFFFEF2F2),
      side: BorderSide(
        color: selected ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryColor : const Color(0xFF64748B),
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      visualDensity: VisualDensity.compact,
    );
  }
}
