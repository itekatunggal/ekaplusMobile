import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';

enum LoyaltyCalculationStatus { initial, loading, success, failure }

class LoyaltyCalculationState {
  const LoyaltyCalculationState({
    this.status = LoyaltyCalculationStatus.initial,
    this.historyStatus = LoyaltyCalculationStatus.initial,
    this.ledger,
    this.details = const [],
    this.history = const [],
    this.categoryIcons = const {},
  });

  final LoyaltyCalculationStatus status;
  final LoyaltyCalculationStatus historyStatus;
  final LoyaltyLedger? ledger;
  final List<LoyaltyEarningDetail> details;
  final List<LoyaltyRedemption> history;
  final Map<String, String> categoryIcons;

  LoyaltyCalculationState copyWith({
    LoyaltyCalculationStatus? status,
    LoyaltyCalculationStatus? historyStatus,
    LoyaltyLedger? ledger,
    List<LoyaltyEarningDetail>? details,
    List<LoyaltyRedemption>? history,
    Map<String, String>? categoryIcons,
  }) => LoyaltyCalculationState(
    status: status ?? this.status,
    historyStatus: historyStatus ?? this.historyStatus,
    ledger: ledger ?? this.ledger,
    details: details ?? this.details,
    history: history ?? this.history,
    categoryIcons: categoryIcons ?? this.categoryIcons,
  );
}

class LoyaltyCalculationCubit extends Cubit<LoyaltyCalculationState> {
  LoyaltyCalculationCubit(this._service, this.gpid, {this.bcid})
    : super(const LoyaltyCalculationState());

  final LoyaltyService _service;
  final int gpid;
  final String? bcid;

  Future<void> load() async {
    await Future.wait([loadCalculation(), loadHistory()]);
  }

  Future<void> loadCalculation() async {
    emit(state.copyWith(status: LoyaltyCalculationStatus.loading));
    try {
      final ledger = await _service.getActiveLedger(gpid);
      if (ledger == null || ledger.calculationId <= 0) {
        if (!isClosed) {
          emit(
            LoyaltyCalculationState(
              status: LoyaltyCalculationStatus.success,
              historyStatus: state.historyStatus,
              history: state.history,
            ),
          );
        }
        return;
      }
      final categoryIconsFuture = _service.getCategoryIcons().catchError(
        (_) => <String, String>{},
      );
      final details = await _service.getCalculationDetails(
        ledger.calculationId,
      );
      final categoryIcons = await categoryIconsFuture;
      details.sort((a, b) {
        final pointOrder = b.awardedPoint.compareTo(a.awardedPoint);
        return pointOrder != 0
            ? pointOrder
            : b.purchaseAmount.compareTo(a.purchaseAmount);
      });
      if (!isClosed) {
        emit(
          state.copyWith(
            status: LoyaltyCalculationStatus.success,
            ledger: ledger,
            details: details,
            categoryIcons: categoryIcons,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(status: LoyaltyCalculationStatus.failure));
      }
    }
  }

  Future<void> loadHistory() async {
    final normalizedBcid = bcid?.trim() ?? '';
    if (normalizedBcid.isEmpty) {
      emit(
        state.copyWith(
          historyStatus: LoyaltyCalculationStatus.success,
          history: const [],
        ),
      );
      return;
    }
    emit(state.copyWith(historyStatus: LoyaltyCalculationStatus.loading));
    try {
      final history = await _service.getHistory(normalizedBcid, limit: 3);
      if (!isClosed) {
        emit(
          state.copyWith(
            historyStatus: LoyaltyCalculationStatus.success,
            history: history,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(historyStatus: LoyaltyCalculationStatus.failure));
      }
    }
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
