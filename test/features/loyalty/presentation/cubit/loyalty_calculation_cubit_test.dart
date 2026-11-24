import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_calculation_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'timeline combines earned and approved used points by latest date',
    () async {
      final ledger = LoyaltyLedger(
        calculationId: 12,
        calculationName: 'CALC-12',
        earnedPoint: 75,
        periodName: 'Juni 2026',
        ready: true,
        expired: false,
        validFrom: DateTime(2026, 6),
      );
      final service = _FakeLoyaltyService(
        ledger: ledger,
        details: const [
          LoyaltyEarningDetail(
            account: 'Penjualan Kain',
            category: 'Kain',
            purchaseAmount: 1000000,
            pointDivider: 10000,
            awardedPoint: 100,
          ),
        ],
        redemptions: [
          LoyaltyRedemption(
            id: 'approved',
            name: 'RED-1',
            status: LoyaltyRedemptionStatus.approved,
            pointUsed: 25,
            rewardName: 'Voucher Belanja',
            completedAt: DateTime(2026, 6, 20),
          ),
          LoyaltyRedemption(
            id: 'pending',
            name: 'RED-2',
            status: LoyaltyRedemptionStatus.pending,
            pointUsed: 50,
            rewardName: 'Reward Pending',
            createdAt: DateTime(2026, 6, 21),
          ),
        ],
      );
      final cubit = LoyaltyCalculationCubit(
        service,
        7,
        bcid: 'BC-1',
        useDummyData: false,
      );

      await cubit.load();

      expect(cubit.state.status, LoyaltyCalculationStatus.success);
      expect(cubit.state.activities, hasLength(2));
      expect(cubit.state.activities.map((activity) => activity.id), [
        'used-approved',
        'earned-12',
      ]);
      expect(cubit.state.activities.first.point, 25);
      expect(cubit.state.activities.last.point, 100);
      expect(cubit.state.activities.last.type, LoyaltyPointActivityType.earned);

      await cubit.close();
    },
  );
}

class _FakeLoyaltyService extends LoyaltyService {
  _FakeLoyaltyService({
    required this.ledger,
    required this.details,
    required this.redemptions,
  });

  final LoyaltyLedger ledger;
  final List<LoyaltyEarningDetail> details;
  final List<LoyaltyRedemption> redemptions;

  @override
  Future<LoyaltyLedger?> getActiveLedger(int gpid) async => ledger;

  @override
  Future<List<LoyaltyLedger>> getLedgerHistory(
    int gpid, {
    int limit = 12,
  }) async => [ledger];

  @override
  Future<List<LoyaltyEarningDetail>> getCalculationDetails(
    int calculationId,
  ) async => details;

  @override
  Future<List<LoyaltyRedemption>> getHistory(
    String bcid, {
    int limit = 20,
    int? offset,
  }) async => redemptions;
}
