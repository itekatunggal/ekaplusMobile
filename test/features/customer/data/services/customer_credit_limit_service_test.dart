import 'dart:convert';

import 'package:ekaplus_ekatunggal/features/customer/data/services/customer_credit_limit_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerCreditLimitService.parseResponse', () {
    test('parses policy and calculates remaining credit and used ratio', () {
      final policy = CustomerCreditLimitService.parseResponse(
        jsonEncode({
          'status': 'success',
          'data': {
            'policy': {
              'bcid': 'BGR00039',
              'credit_limit_level': 'nbid',
              'final_credit_limit': 4500000000,
              'gcid': 39,
              'gpid': 36,
              'nbid': 1,
              'total_limit_outstanding': 4180690802,
            },
          },
        }),
      );

      expect(policy.bcid, 'BGR00039');
      expect(policy.creditLimitLevel, 'nbid');
      expect(policy.nbid, 1);
      expect(policy.gpid, 36);
      expect(policy.gcid, 39);
      expect(policy.finalCreditLimit, 4500000000);
      expect(policy.totalLimitOutstanding, 4180690802);
      expect(policy.remainingCredit, 319309198);
      expect(policy.usedRatio, closeTo(0.9290424004, 0.0000000001));
      expect(policy.creditLimitLevelLabel, 'National Brand');
      expect(policy.creditLimitSourceLabel, 'National Brand');
    });

    test('reads an active payment term as TOP days', () {
      expect(
        CustomerCreditLimitService.paymentTermFromData({
          'payment_term': 90,
          'payment_term_active': 1,
        }),
        90,
      );
      expect(
        CustomerCreditLimitService.paymentTermFromData({
          'payment_term': 30,
          'payment_term_active': 0,
        }),
        isNull,
      );
      expect(
        CustomerCreditLimitService.paymentTermFromData({
          'payment_term': <dynamic>[90],
          'payment_term_active': 1,
        }),
        isNull,
      );
    });

    test('builds a clear credit limit source label', () {
      final policy = CustomerCreditLimitService.parseResponse(
        jsonEncode({
          'data': {
            'policy': {
              'bcid': 'BGR00039',
              'credit_limit_level': 'nbid',
              'final_credit_limit': 4500000000,
              'nbid': 1,
              'total_limit_outstanding': 0,
            },
          },
        }),
      ).copyWith(limitOwnerName: 'KANGAROO', paymentTermDays: 90);

      expect(policy.creditLimitSourceLabel, 'National Brand • KANGAROO');
      expect(policy.paymentTermDays, 90);
    });

    test('maps every dynamic limit level to its display name field', () {
      expect(
        CustomerCreditLimitService.resourceNameFromData('nbid', {
          'nb_name': 'KANGAROO',
        }),
        'KANGAROO',
      );
      expect(
        CustomerCreditLimitService.resourceNameFromData('gpid', {
          'gp_name': 'A 2 SOFA GROUP',
        }),
        'A 2 SOFA GROUP',
      );
      expect(
        CustomerCreditLimitService.resourceNameFromData('gcid', {
          'gc_name': 'A 2 SOFA HI',
        }),
        'A 2 SOFA HI',
      );
      expect(
        CustomerCreditLimitService.resourceNameFromData('bcid', {
          'gcid': {'company_name': 'A 2 SOFA HI'},
        }),
        'A 2 SOFA HI',
      );
    });

    test('rejects a response without policy data', () {
      expect(
        () => CustomerCreditLimitService.parseResponse(
          jsonEncode({'status': 'success', 'data': {}}),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('recognizes a successful policy response without a credit limit', () {
      final policy = CustomerCreditLimitService.parseResponse(
        jsonEncode({
          'status': 'success',
          'data': {
            'policy': {
              'bcid': 'BGR00553',
              'credit_limit_level': 'none',
              'final_credit_limit': 0,
              'gcid': 1978,
              'gpid': 1819,
              'nbid': null,
              'total_limit_outstanding': 0,
            },
          },
        }),
      );

      expect(policy.hasCreditLimit, isFalse);
      expect(policy.remainingCredit, 0);
      expect(policy.usedRatio, 0);
    });
  });
}
