import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';

enum CustomerPointSummaryStatus { initial, loading, success, failure }

class CustomerPointSummaryState {
  const CustomerPointSummaryState({
    this.status = CustomerPointSummaryStatus.initial,
    this.gpid,
    this.bcid,
    this.availablePoint = 0,
    this.nearestExpiry,
    this.periodName,
    this.calculationId,
    this.ready = false,
  });

  final CustomerPointSummaryStatus status;
  final int? gpid;
  final String? bcid;
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

  Future<void> load(int? gpid, {String? bcid}) async {
    final version = ++_requestVersion;
    final normalizedBcid = bcid?.trim() ?? '';
    if (gpid == null || gpid <= 0 || normalizedBcid.isEmpty) {
      emit(const CustomerPointSummaryState());
      return;
    }
    final previous = state;
    final hasExistingData =
        previous.gpid == gpid &&
        previous.bcid == normalizedBcid &&
        previous.status == CustomerPointSummaryStatus.success;
    if (!hasExistingData) {
      emit(
        CustomerPointSummaryState(
          status: CustomerPointSummaryStatus.loading,
          gpid: gpid,
          bcid: normalizedBcid,
        ),
      );
    }
    try {
      final balance = await _service.getBalance(normalizedBcid);
      if (version != _requestVersion || isClosed) return;
      final activeExpiries =
          balance.buckets
              .where((bucket) => !bucket.expired && bucket.validTo != null)
              .map((bucket) => bucket.validTo!)
              .toList(growable: false)
            ..sort();
      emit(
        CustomerPointSummaryState(
          status: CustomerPointSummaryStatus.success,
          gpid: gpid,
          bcid: normalizedBcid,
          availablePoint: balance.availablePoint,
          nearestExpiry: activeExpiries.isEmpty ? null : activeExpiries.first,
          ready: balance.buckets.any((bucket) => bucket.ready),
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
            bcid: normalizedBcid,
          ),
        );
      }
    }
  }
}
