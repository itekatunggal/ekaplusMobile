import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_point_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/pages/loyalty_reward_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyRewardListPage extends StatelessWidget {
  const LoyaltyRewardListPage({super.key});

  static void openDetail(BuildContext context, LoyaltyReward reward) {
    final cubit = context.read<LoyaltyPointCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: LoyaltyRewardDetailPage(reward: reward),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Reward Ekaplus',
    body: BlocBuilder<LoyaltyPointCubit, LoyaltyPointState>(
      builder: (context, state) {
        final available = state.balance?.availablePoint ?? 0;
        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async => Future.wait([
            context.read<LoyaltyPointCubit>().loadBalance(),
            context.read<LoyaltyPointCubit>().loadRewards(),
          ]),
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              LoyaltySectionCard(
                title: 'Pilihan Reward',
                child: state.rewardStatus == LoyaltySectionStatus.loading
                    ? const LoyaltyLoading(height: 150)
                    : state.rewardStatus == LoyaltySectionStatus.failure
                    ? LoyaltySectionMessage(
                        message: 'Reward belum dapat dimuat.',
                        onRetry: context.read<LoyaltyPointCubit>().loadRewards,
                      )
                    : state.rewards.isEmpty
                    ? const LoyaltySectionMessage(
                        message: 'Reward belum tersedia saat ini.',
                        icon: Icons.card_giftcard_outlined,
                      )
                    : LoyaltyDividedList(
                        children: state.rewards
                            .map(
                              (reward) => LoyaltyRewardTile(
                                reward: reward,
                                availablePoint: available,
                                onTap: () => openDetail(context, reward),
                              ),
                            )
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
