import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoyaltyLedger', () {
    test('uses earned_point directly as the customer balance', () {
      final ledger = LoyaltyLedger.fromJson({
        'calculation_id': 36,
        'calculation_name': 'CALC-36',
        'earned_point': 237,
        'used_point': 100,
        'period_name': 'LOYALTY-2026',
        'ready': 1,
        'expired': 0,
      });

      expect(ledger.earnedPoint, 237);
      expect(ledger.calculationId, 36);
      expect(ledger.ready, isTrue);
      expect(ledger.expired, isFalse);
    });
  });

  group('LoyaltyEarnings', () {
    test('keeps positive purchases that award zero points', () {
      final earnings = LoyaltyEarnings.fromJson({
        'period_name': 'LOYALTY-2026',
        'total_point': 0,
        'rows': [
          {
            'account': 'Penjualan Accessories',
            'omzet_snapshot': 2850000,
            'standard_divider_snapshot': 20000000,
            'awarded_point': 0,
            'calculation_id': 36,
          },
          {
            'account': 'Penjualan Busa',
            'omzet_snapshot': 0,
            'standard_divider_snapshot': 20000000,
            'awarded_point': 0,
            'calculation_id': 36,
          },
        ],
      });

      expect(earnings.rows, hasLength(1));
      expect(earnings.rows.single.account, 'Penjualan Accessories');
      expect(earnings.rows.single.category, 'Accessories');
      expect(earnings.rows.single.awardedPoint, 0);
    });
  });

  test('LoyaltyPurchaseSource maps only customer-facing source data', () {
    final source = LoyaltyPurchaseSource.fromJson({
      'account': 'Penjualan Kimia',
      'omzet': 852864375,
      'branch_id': 56,
      'bc_refs': 'BGR00039',
      'customer_count': 1,
      'calculation_id': 36,
    });

    expect(source.account, 'Penjualan Kimia');
    expect(source.purchaseAmount, 852864375);
    expect(source.branchId, 56);
    expect(source.bcReference, 'BGR00039');
  });
}
