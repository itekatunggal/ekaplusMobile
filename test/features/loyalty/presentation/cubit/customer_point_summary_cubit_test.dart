import 'dart:async';

import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/customer_point_summary_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLoyaltyService extends LoyaltyService {
  _FakeLoyaltyService(this.balance);

  final LoyaltyBalance balance;
  String? requestedBcid;

  @override
  Future<LoyaltyBalance> getBalance(String bcid) async {
    requestedBcid = bcid;
    return balance;
  }
}

class _ControlledLoyaltyService extends LoyaltyService {
  final requests = <String, Completer<LoyaltyBalance>>{};

  @override
  Future<LoyaltyBalance> getBalance(String bcid) {
    final request = Completer<LoyaltyBalance>();
    requests[bcid] = request;
    return request.future;
  }
}

void main() {
  test(
    'summary displays API available point instead of earned point',
    () async {
      final service = _FakeLoyaltyService(
        const LoyaltyBalance(
          totalPoint: 150,
          redeemedPoint: 30,
          reservedPoint: 20,
          availablePoint: 100,
          buckets: [],
        ),
      );
      final cubit = CustomerPointSummaryCubit(service);

      await cubit.load(7, bcid: 'BCID-10');

      expect(service.requestedBcid, 'BCID-10');
      expect(cubit.state.status, CustomerPointSummaryStatus.success);
      expect(cubit.state.availablePoint, 100);
      expect(cubit.state.bcid, 'BCID-10');
      await cubit.close();
    },
  );

  test(
    'summary dibersihkan ketika session tidak memiliki GPID atau BCID',
    () async {
      final service = _FakeLoyaltyService(
        const LoyaltyBalance(
          totalPoint: 130,
          redeemedPoint: 20,
          reservedPoint: 10,
          availablePoint: 100,
          buckets: [],
        ),
      );
      final cubit = CustomerPointSummaryCubit(service);

      await cubit.load(7, bcid: 'BCID-10');
      await cubit.load(null);

      expect(cubit.state.status, CustomerPointSummaryStatus.initial);
      expect(cubit.state.gpid, isNull);
      expect(cubit.state.bcid, isNull);
      expect(cubit.state.availablePoint, 0);
      await cubit.close();
    },
  );

  test('response BCID lama tidak menimpa BCID akun yang baru', () async {
    final service = _ControlledLoyaltyService();
    final cubit = CustomerPointSummaryCubit(service);

    final oldRequest = cubit.load(7, bcid: 'BCID-A');
    final newRequest = cubit.load(8, bcid: 'BCID-B');
    service.requests['BCID-B']!.complete(
      const LoyaltyBalance(
        totalPoint: 200,
        redeemedPoint: 0,
        reservedPoint: 0,
        availablePoint: 200,
        buckets: [],
      ),
    );
    await newRequest;
    service.requests['BCID-A']!.complete(
      const LoyaltyBalance(
        totalPoint: 999,
        redeemedPoint: 0,
        reservedPoint: 0,
        availablePoint: 999,
        buckets: [],
      ),
    );
    await oldRequest;

    expect(cubit.state.gpid, 8);
    expect(cubit.state.bcid, 'BCID-B');
    expect(cubit.state.availablePoint, 200);
    await cubit.close();
  });
}
