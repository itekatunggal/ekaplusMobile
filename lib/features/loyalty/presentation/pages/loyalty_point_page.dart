import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_point_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/pages/loyalty_earning_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/pages/loyalty_history_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/pages/loyalty_reward_list_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyPointPage extends StatelessWidget {
  const LoyaltyPointPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomHeaderScaffold(
      title: 'Poin Ekaplus',
      subtitle: 'Reward untuk setiap pembelian Anda',
      body: BlocBuilder<LoyaltyPointCubit, LoyaltyPointState>(
        builder: (context, state) => RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: context.read<LoyaltyPointCubit>().loadAll,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              _balance(context, state),
              const SizedBox(height: 14),
              _earnings(context, state),
              const SizedBox(height: 14),
              _rewards(context, state),
              const SizedBox(height: 14),
              _history(context, state),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balance(BuildContext context, LoyaltyPointState state) {
    if (state.balanceStatus == LoyaltySectionStatus.loading &&
        state.balance == null) {
      return const LoyaltySectionCard(
        title: 'Saldo Poin',
        child: LoyaltyLoading(height: 128),
      );
    }
    if (state.balanceStatus == LoyaltySectionStatus.failure &&
        state.balance == null) {
      return LoyaltySectionCard(
        title: 'Saldo Poin',
        child: LoyaltySectionMessage(
          message: 'Saldo poin belum dapat dimuat.',
          icon: Icons.account_balance_wallet_outlined,
          onRetry: context.read<LoyaltyPointCubit>().loadBalance,
        ),
      );
    }
    final balance = state.balance;
    if (balance == null) return const SizedBox.shrink();
    return Column(
      children: [
        LoyaltyBalanceCard(balance: balance),
        LoyaltyBucketNotice(balance: balance),
      ],
    );
  }

  Widget _earnings(BuildContext context, LoyaltyPointState state) {
    final rows = state.earnings?.rows.take(3).toList() ?? const [];
    return LoyaltySectionCard(
      title: 'Perolehan Poin',
      onSeeAll: state.earnings != null
          ? () => _push(context, const LoyaltyEarningDetailPage())
          : null,
      child: _sectionContent(
        status: state.earningStatus,
        empty: rows.isEmpty,
        emptyMessage: 'Belum ada perolehan poin pada periode ini.',
        retry: context.read<LoyaltyPointCubit>().loadEarnings,
        content: LoyaltyDividedList(
          children: rows.map((item) => LoyaltyEarningTile(item: item)).toList(),
        ),
      ),
    );
  }

  Widget _rewards(BuildContext context, LoyaltyPointState state) {
    final rows = state.rewards.take(3).toList();
    final available = state.balance?.availablePoint ?? 0;
    return LoyaltySectionCard(
      title: 'Reward',
      onSeeAll: state.rewardStatus == LoyaltySectionStatus.success
          ? () => _push(context, const LoyaltyRewardListPage())
          : null,
      child: _sectionContent(
        status: state.rewardStatus,
        empty: rows.isEmpty,
        emptyMessage: 'Reward belum tersedia saat ini.',
        retry: context.read<LoyaltyPointCubit>().loadRewards,
        content: LoyaltyDividedList(
          children: rows
              .map(
                (reward) => LoyaltyRewardTile(
                  reward: reward,
                  availablePoint: available,
                  onTap: () =>
                      LoyaltyRewardListPage.openDetail(context, reward),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _history(BuildContext context, LoyaltyPointState state) {
    final rows = state.history.take(3).toList();
    return LoyaltySectionCard(
      title: 'Aktivitas Terbaru',
      onSeeAll: state.historyStatus == LoyaltySectionStatus.success
          ? () => _push(context, const LoyaltyHistoryPage())
          : null,
      child: _sectionContent(
        status: state.historyStatus,
        empty: rows.isEmpty,
        emptyMessage: 'Belum ada aktivitas penukaran poin.',
        retry: context.read<LoyaltyPointCubit>().loadHistory,
        content: LoyaltyDividedList(
          children: rows
              .map(
                (item) => LoyaltyHistoryTile(
                  item: item,
                  onTap: () => LoyaltyHistoryPage.openDetail(context, item),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _sectionContent({
    required LoyaltySectionStatus status,
    required bool empty,
    required String emptyMessage,
    required VoidCallback retry,
    required Widget content,
  }) {
    if (status == LoyaltySectionStatus.loading) return const LoyaltyLoading();
    if (status == LoyaltySectionStatus.failure) {
      return LoyaltySectionMessage(
        message: 'Data belum dapat dimuat.',
        onRetry: retry,
        icon: Icons.cloud_off_outlined,
      );
    }
    if (empty) return LoyaltySectionMessage(message: emptyMessage);
    return content;
  }

  void _push(BuildContext context, Widget page) {
    final cubit = context.read<LoyaltyPointCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(value: cubit, child: page),
      ),
    );
  }
}
