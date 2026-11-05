import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';

enum LoyaltySectionStatus { initial, loading, success, failure }

class LoyaltyPointState {
  const LoyaltyPointState({
    required this.bcid,
    this.balanceStatus = LoyaltySectionStatus.initial,
    this.earningStatus = LoyaltySectionStatus.initial,
    this.rewardStatus = LoyaltySectionStatus.initial,
    this.historyStatus = LoyaltySectionStatus.initial,
    this.balance,
    this.earnings,
    this.rewards = const [],
    this.history = const [],
    this.historyLoadingMore = false,
    this.historyHasMore = true,
  });

  final String bcid;
  final LoyaltySectionStatus balanceStatus;
  final LoyaltySectionStatus earningStatus;
  final LoyaltySectionStatus rewardStatus;
  final LoyaltySectionStatus historyStatus;
  final LoyaltyBalance? balance;
  final LoyaltyEarnings? earnings;
  final List<LoyaltyReward> rewards;
  final List<LoyaltyRedemption> history;
  final bool historyLoadingMore;
  final bool historyHasMore;

  LoyaltyPointState copyWith({
    LoyaltySectionStatus? balanceStatus,
    LoyaltySectionStatus? earningStatus,
    LoyaltySectionStatus? rewardStatus,
    LoyaltySectionStatus? historyStatus,
    LoyaltyBalance? balance,
    LoyaltyEarnings? earnings,
    List<LoyaltyReward>? rewards,
    List<LoyaltyRedemption>? history,
    bool? historyLoadingMore,
    bool? historyHasMore,
  }) => LoyaltyPointState(
    bcid: bcid,
    balanceStatus: balanceStatus ?? this.balanceStatus,
    earningStatus: earningStatus ?? this.earningStatus,
    rewardStatus: rewardStatus ?? this.rewardStatus,
    historyStatus: historyStatus ?? this.historyStatus,
    balance: balance ?? this.balance,
    earnings: earnings ?? this.earnings,
    rewards: rewards ?? this.rewards,
    history: history ?? this.history,
    historyLoadingMore: historyLoadingMore ?? this.historyLoadingMore,
    historyHasMore: historyHasMore ?? this.historyHasMore,
  );
}

class LoyaltyPointCubit extends Cubit<LoyaltyPointState> {
  LoyaltyPointCubit(this._service, String bcid)
    : super(LoyaltyPointState(bcid: bcid));

  final LoyaltyService _service;

  Future<void> loadAll() async {
    await Future.wait([
      loadBalance(),
      loadEarnings(),
      loadRewards(),
      loadHistory(),
    ]);
  }

  Future<void> loadBalance() async {
    emit(state.copyWith(balanceStatus: LoyaltySectionStatus.loading));
    try {
      final value = await _service.getBalance(state.bcid);
      if (!isClosed) {
        emit(
          state.copyWith(
            balanceStatus: LoyaltySectionStatus.success,
            balance: value,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(balanceStatus: LoyaltySectionStatus.failure));
      }
    }
  }

  Future<void> loadEarnings() async {
    emit(state.copyWith(earningStatus: LoyaltySectionStatus.loading));
    try {
      final value = await _service.getEarnings(state.bcid);
      if (!isClosed) {
        emit(
          state.copyWith(
            earningStatus: LoyaltySectionStatus.success,
            earnings: value,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(earningStatus: LoyaltySectionStatus.failure));
      }
    }
  }

  Future<void> loadRewards() async {
    emit(state.copyWith(rewardStatus: LoyaltySectionStatus.loading));
    try {
      final value = await _service.getRewards(state.bcid);
      if (!isClosed) {
        emit(
          state.copyWith(
            rewardStatus: LoyaltySectionStatus.success,
            rewards: value,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(rewardStatus: LoyaltySectionStatus.failure));
      }
    }
  }

  Future<void> loadHistory() async {
    emit(state.copyWith(historyStatus: LoyaltySectionStatus.loading));
    try {
      final value = await _service.getHistory(state.bcid, limit: 20);
      if (!isClosed) {
        emit(
          state.copyWith(
            historyStatus: LoyaltySectionStatus.success,
            history: value,
            historyHasMore: value.length == 20,
            historyLoadingMore: false,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(historyStatus: LoyaltySectionStatus.failure));
      }
    }
  }

  Future<void> loadMoreHistory() async {
    if (state.historyLoadingMore || !state.historyHasMore) return;
    emit(state.copyWith(historyLoadingMore: true));
    try {
      final value = await _service.getHistory(
        state.bcid,
        limit: 20,
        offset: state.history.length,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            history: [...state.history, ...value],
            historyHasMore: value.length == 20,
            historyLoadingMore: false,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(historyLoadingMore: false));
      }
    }
  }

  Future<LoyaltyRedemptionStatus> redeem(
    LoyaltyReward reward,
    int quantity, {
    String? idempotencyKey,
  }) async {
    final key =
        idempotencyKey ??
        '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    final result = await _service.redeem(
      bcid: state.bcid,
      rewardId: reward.id,
      quantity: quantity,
      idempotencyKey: key,
    );
    await Future.wait([loadBalance(), loadRewards(), loadHistory()]);
    return result;
  }
}
