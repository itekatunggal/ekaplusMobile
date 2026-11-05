import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_point_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyEarningDetailPage extends StatelessWidget {
  const LoyaltyEarningDetailPage({super.key});
  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Perolehan Poin',
    body: BlocBuilder<LoyaltyPointCubit, LoyaltyPointState>(
      builder: (context, state) {
        final data = state.earnings;
        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: context.read<LoyaltyPointCubit>().loadEarnings,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (data != null)
                _Summary(period: data.periodName, total: data.totalPoint),
              if (data != null) const SizedBox(height: 14),
              LoyaltySectionCard(
                title: 'Rincian Pembelian',
                child: state.earningStatus == LoyaltySectionStatus.loading
                    ? const LoyaltyLoading(height: 140)
                    : state.earningStatus == LoyaltySectionStatus.failure
                    ? LoyaltySectionMessage(
                        message: 'Perolehan poin belum dapat dimuat.',
                        onRetry: context.read<LoyaltyPointCubit>().loadEarnings,
                      )
                    : data == null || data.rows.isEmpty
                    ? const LoyaltySectionMessage(
                        message: 'Belum ada perolehan poin pada periode ini.',
                      )
                    : LoyaltyDividedList(
                        children: data.rows
                            .map((item) => LoyaltyEarningTile(item: item))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.period, required this.total});
  final String period;
  final int total;
  @override
  Widget build(BuildContext context) => Container(
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
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Periode',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
              ),
              Text(
                period,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Total Diperoleh',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
            ),
            Text(
              formatPoint(total),
              style: const TextStyle(
                color: Color(0xFF059669),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
