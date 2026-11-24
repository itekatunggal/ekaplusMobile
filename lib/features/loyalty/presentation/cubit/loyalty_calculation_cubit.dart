import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:flutter/foundation.dart';

enum LoyaltyCalculationStatus { initial, loading, success, failure }

class LoyaltyCalculationState {
  const LoyaltyCalculationState({
    this.status = LoyaltyCalculationStatus.initial,
    this.ledger,
    this.activities = const [],
  });

  final LoyaltyCalculationStatus status;
  final LoyaltyLedger? ledger;
  final List<LoyaltyPointActivity> activities;

  LoyaltyCalculationState copyWith({
    LoyaltyCalculationStatus? status,
    LoyaltyLedger? ledger,
    List<LoyaltyPointActivity>? activities,
  }) => LoyaltyCalculationState(
    status: status ?? this.status,
    ledger: ledger ?? this.ledger,
    activities: activities ?? this.activities,
  );
}

class LoyaltyCalculationCubit extends Cubit<LoyaltyCalculationState> {
  LoyaltyCalculationCubit(
    this._service,
    this.gpid, {
    this.bcid,
    this.useDummyData = kDebugMode,
  }) : super(const LoyaltyCalculationState());

  final LoyaltyService _service;
  final int gpid;
  final String? bcid;
  final bool useDummyData;
  int _calculationRequestVersion = 0;

  Future<void> load() async {
    await loadCalculation();
  }

  Future<void> loadCalculation() async {
    final version = ++_calculationRequestVersion;
    final hasExistingData = state.status == LoyaltyCalculationStatus.success;
    if (!hasExistingData) {
      emit(state.copyWith(status: LoyaltyCalculationStatus.loading));
    }
    if (useDummyData) {
      emit(_dummyState());
      return;
    }
    try {
      final normalizedBcid = bcid?.trim() ?? '';
      final results = await Future.wait<Object?>([
        _service.getActiveLedger(gpid),
        _service.getLedgerHistory(gpid),
        if (normalizedBcid.isNotEmpty)
          _service
              .getHistory(normalizedBcid, limit: 100)
              .catchError((_) => <LoyaltyRedemption>[])
        else
          Future.value(const <LoyaltyRedemption>[]),
      ]);
      final ledger = results[0] as LoyaltyLedger?;
      final ledgers = results[1] as List<LoyaltyLedger>;
      final redemptions = results[2] as List<LoyaltyRedemption>;
      if (version != _calculationRequestVersion || isClosed) return;

      final detailGroups = await Future.wait(
        ledgers.map(
          (item) => _service
              .getCalculationDetails(item.calculationId)
              .catchError((_) => <LoyaltyEarningDetail>[]),
        ),
      );
      if (version != _calculationRequestVersion || isClosed) return;

      final activities =
          <LoyaltyPointActivity>[
            for (var index = 0; index < ledgers.length; index++)
              if (_earnedPoint(detailGroups[index], ledgers[index]) > 0)
                LoyaltyPointActivity(
                  id: 'earned-${ledgers[index].calculationId}',
                  title: 'Poin dari pembelian',
                  description: ledgers[index].periodName,
                  point: _earnedPoint(detailGroups[index], ledgers[index]),
                  type: LoyaltyPointActivityType.earned,
                  occurredAt: ledgers[index].validFrom,
                ),
            for (final redemption in redemptions)
              if (redemption.status == LoyaltyRedemptionStatus.approved &&
                  redemption.pointUsed > 0)
                LoyaltyPointActivity(
                  id: 'used-${redemption.id}',
                  title: redemption.rewardName,
                  description: 'Penggunaan poin',
                  point: redemption.pointUsed,
                  type: LoyaltyPointActivityType.used,
                  occurredAt: redemption.completedAt ?? redemption.createdAt,
                ),
          ]..sort((first, second) {
            final firstDate = first.occurredAt;
            final secondDate = second.occurredAt;
            if (firstDate == null && secondDate == null) return 0;
            if (firstDate == null) return 1;
            if (secondDate == null) return -1;
            return secondDate.compareTo(firstDate);
          });

      emit(
        state.copyWith(
          status: LoyaltyCalculationStatus.success,
          ledger: ledger,
          activities: activities,
        ),
      );
    } catch (_) {
      if (version != _calculationRequestVersion || isClosed) return;
      if (!hasExistingData) {
        emit(state.copyWith(status: LoyaltyCalculationStatus.failure));
      }
    }
  }

  int _earnedPoint(List<LoyaltyEarningDetail> details, LoyaltyLedger ledger) {
    final calculated = details.fold<int>(
      0,
      (total, detail) => total + detail.awardedPoint,
    );
    return calculated > 0 ? calculated : ledger.earnedPoint;
  }

  LoyaltyCalculationState _dummyState() {
    return LoyaltyCalculationState(
      status: LoyaltyCalculationStatus.success,
      ledger: LoyaltyLedger(
        calculationId: 999,
        calculationName: 'DUMMY-2026',
        earnedPoint: 7850,
        periodName: 'Periode 2026',
        ready: true,
        expired: false,
        validFrom: DateTime(2026, 1),
      ),
      activities: [
        LoyaltyPointActivity(
          id: 'dummy-1',
          title: 'Poin dari pembelian',
          description: 'Perolehan transaksi November',
          point: 1250,
          type: LoyaltyPointActivityType.earned,
          occurredAt: DateTime(2026, 11, 18),
        ),
        LoyaltyPointActivity(
          id: 'dummy-2',
          title: 'Voucher Belanja Rp100.000',
          description: 'Penggunaan poin',
          point: 2000,
          type: LoyaltyPointActivityType.used,
          occurredAt: DateTime(2026, 11, 10),
        ),
        LoyaltyPointActivity(
          id: 'dummy-8',
          title: 'Poin dari pembelian cabang Balikpapan',
          description: 'Bonus transaksi produk pilihan',
          point: 875,
          type: LoyaltyPointActivityType.earned,
          occurredAt: DateTime(2026, 11, 8),
        ),
        LoyaltyPointActivity(
          id: 'dummy-9',
          title: 'Voucher Potongan Rp25.000',
          description: 'Penukaran reward EkaPoint',
          point: 500,
          type: LoyaltyPointActivityType.used,
          occurredAt: DateTime(2026, 11, 5),
        ),
        LoyaltyPointActivity(
          id: 'dummy-3',
          title: 'Bonus loyalitas customer',
          description: 'Bonus program EkaPoint',
          point: 500,
          type: LoyaltyPointActivityType.earned,
          occurredAt: DateTime(2026, 11, 2),
        ),
        LoyaltyPointActivity(
          id: 'dummy-10',
          title: 'Bonus transaksi awal bulan',
          description: 'Program bonus EkaPoint November',
          point: 325,
          type: LoyaltyPointActivityType.earned,
          occurredAt: DateTime(2026, 11),
        ),
        LoyaltyPointActivity(
          id: 'dummy-4',
          title: 'Poin dari pembelian',
          description: 'Perolehan transaksi Oktober',
          point: 3100,
          type: LoyaltyPointActivityType.earned,
          occurredAt: DateTime(2026, 10, 24),
        ),
        LoyaltyPointActivity(
          id: 'dummy-5',
          title: 'Voucher Gratis Ongkir',
          description: 'Penggunaan poin',
          point: 750,
          type: LoyaltyPointActivityType.used,
          occurredAt: DateTime(2026, 10, 12),
        ),
        LoyaltyPointActivity(
          id: 'dummy-6',
          title: 'Poin dari pembelian',
          description: 'Perolehan transaksi September',
          point: 2250,
          type: LoyaltyPointActivityType.earned,
          occurredAt: DateTime(2026, 9, 26),
        ),
        LoyaltyPointActivity(
          id: 'dummy-7',
          title: 'Voucher Belanja Rp50.000',
          description: 'Penggunaan poin',
          point: 1000,
          type: LoyaltyPointActivityType.used,
          occurredAt: DateTime(2026, 9, 8),
        ),
      ],
    );
  }
}

class LoyaltySourceState {
  const LoyaltySourceState({
    this.status = LoyaltyCalculationStatus.initial,
    this.items = const [],
    this.loadingMore = false,
    this.hasMore = true,
  });

  final LoyaltyCalculationStatus status;
  final List<LoyaltyPurchaseSource> items;
  final bool loadingMore;
  final bool hasMore;

  LoyaltySourceState copyWith({
    LoyaltyCalculationStatus? status,
    List<LoyaltyPurchaseSource>? items,
    bool? loadingMore,
    bool? hasMore,
  }) => LoyaltySourceState(
    status: status ?? this.status,
    items: items ?? this.items,
    loadingMore: loadingMore ?? this.loadingMore,
    hasMore: hasMore ?? this.hasMore,
  );
}

class LoyaltySourceCubit extends Cubit<LoyaltySourceState> {
  LoyaltySourceCubit(
    this._service, {
    required this.calculationId,
    required this.account,
  }) : super(const LoyaltySourceState());

  static const _pageSize = 20;
  final LoyaltyService _service;
  final int calculationId;
  final String account;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: LoyaltyCalculationStatus.loading,
        loadingMore: false,
      ),
    );
    try {
      final items = await _service.getCalculationSources(
        calculationId: calculationId,
        account: account,
        limit: _pageSize,
      );
      if (!isClosed) {
        emit(
          LoyaltySourceState(
            status: LoyaltyCalculationStatus.success,
            items: items,
            hasMore: items.length == _pageSize,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: LoyaltyCalculationStatus.failure,
            loadingMore: false,
          ),
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (state.status != LoyaltyCalculationStatus.success ||
        state.loadingMore ||
        !state.hasMore) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final page = (state.items.length ~/ _pageSize) + 1;
      final more = await _service.getCalculationSources(
        calculationId: calculationId,
        account: account,
        page: page,
        limit: _pageSize,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            items: [...state.items, ...more],
            loadingMore: false,
            hasMore: more.length == _pageSize,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) emit(state.copyWith(loadingMore: false));
    }
  }
}
