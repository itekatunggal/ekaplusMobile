import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';

enum CustomerPointSummaryStatus { initial, loading, success, failure }

class CustomerPointSummaryState {
  const CustomerPointSummaryState({
    this.status = CustomerPointSummaryStatus.initial,
    this.gpid,
    this.availablePoint = 0,
    this.nearestExpiry,
    this.periodName,
    this.calculationId,
    this.ready = false,
  });

  final CustomerPointSummaryStatus status;
  final int? gpid;
  final int availablePoint;
  final DateTime? nearestExpiry;
  final String? periodName;
  final int? calculationId;
  final bool ready;
}

class CustomerPointSummaryCubit extends Cubit<CustomerPointSummaryState> {
  CustomerPointSummaryCubit(this._service)
    : super(const CustomerPointSummaryState());

  final LoyaltyService _service;
  int _requestVersion = 0;

  Future<void> load(int? gpid) async {
    final version = ++_requestVersion;
    if (gpid == null || gpid <= 0) {
      emit(const CustomerPointSummaryState());
      return;
    }
    final previous = state;
    final hasExistingData =
        previous.gpid == gpid &&
        previous.status == CustomerPointSummaryStatus.success;
    if (!hasExistingData) {
      emit(
        CustomerPointSummaryState(
          status: CustomerPointSummaryStatus.loading,
          gpid: gpid,
        ),
      );
    }
    try {
      final ledger = await _service.getActiveLedger(gpid);
      if (version != _requestVersion || isClosed) return;
      emit(
        CustomerPointSummaryState(
          status: CustomerPointSummaryStatus.success,
          gpid: gpid,
          availablePoint: ledger?.earnedPoint ?? 0,
          nearestExpiry: ledger?.validTo,
          periodName: ledger?.periodName,
          calculationId: ledger?.calculationId,
          ready: ledger?.ready ?? false,
        ),
      );
    } catch (_) {
      if (version != _requestVersion || isClosed) return;
      if (hasExistingData) {
        emit(previous);
      } else {
        emit(
          CustomerPointSummaryState(
            status: CustomerPointSummaryStatus.failure,
            gpid: gpid,
          ),
        );
      }
    }
  }
}
